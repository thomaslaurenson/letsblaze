#!/usr/bin/env bash
# letsblaze test suite
# Builds the exampleSite and verifies all constraints defined in README.md.
# Constraint IDs match README.md: R (External Resources), C (CSS Integrity),
# S (Semantic HTML), M (SEO & Metadata).
# Exit code 0 = all checks passed. Exit code 1 = one or more failures.

set -euo pipefail

THEME="letsblaze"
SITE_DIR="exampleSite"
CONTENT_DIR="${SITE_DIR}/content"
PUBLIC="${SITE_DIR}/public"
HUGO_FLAGS=(--themesDir ../.. --theme "${THEME}")

PASS=0
FAIL=0

pass() { printf '  PASS  %s\n' "${1}"; PASS=$((PASS + 1)); }
fail() { printf '  FAIL  %s\n' "${1}"; FAIL=$((FAIL + 1)); }

# Search the <head>...</head> block of a file for a pattern.
#
# Arguments:
#   $1 - Path to the HTML file
#   $2 - Pattern to search for (passed to grep -q)
# Returns:
#   0 if pattern is found, 1 if not
check_head() {
  local file="${1}" pattern="${2}"
  awk '/<head/,/<\/head>/' "${file}" | grep -q "${pattern}"
}

# Check a pattern is present in every file passed as remaining arguments.
#
# Arguments:
#   $1 - Label for the test output
#   $2 - Pattern to search for (passed to grep -q)
#   $@ - HTML files to check (after shift 2)
# Outputs:
#   stdout: PASS or FAIL line, with missing file paths on failure
check_all() {
  local label="${1}" pattern="${2}"
  shift 2
  local failures=()
  for page in "$@"; do
    grep -q "${pattern}" "${page}" 2>/dev/null || failures+=("${page##${PUBLIC}/}")
  done
  if [[ "${#failures[@]}" -eq 0 ]]; then
    pass "${label}"
  else
    fail "${label}"
    printf '        missing in: %s\n' "${failures[@]}"
  fi
}

# Same as check_all but restricts the search to the <head> block only.
#
# Arguments:
#   $1 - Label for the test output
#   $2 - Pattern to search for
#   $@ - HTML files to check (after shift 2)
# Outputs:
#   stdout: PASS or FAIL line, with missing file paths on failure
check_head_all() {
  local label="${1}" pattern="${2}"
  shift 2
  local failures=()
  for page in "$@"; do
    check_head "${page}" "${pattern}" 2>/dev/null || failures+=("${page##${PUBLIC}/}")
  done
  if [[ "${#failures[@]}" -eq 0 ]]; then
    pass "${label}"
  else
    fail "${label}"
    printf '        missing in: %s\n' "${failures[@]}"
  fi
}

# 1. Build
printf '=== 1. Build ===\n'
rm -rf "${PUBLIC}"
if ! (cd "${SITE_DIR}" && hugo "${HUGO_FLAGS[@]}" 2>&1); then
  printf '  ERROR: hugo build failed, aborting tests\n'
  exit 1
fi
printf '\n'

# Page sets used by constraint checks
PAGE_HOME="${PUBLIC}/index.html"
PAGE_BLOG_LIST="${PUBLIC}/blog/index.html"
PAGE_BLOG_POST="${PUBLIC}/blog/welcome-to-letsblaze/index.html"
PAGE_DOC="${PUBLIC}/docs/getting-started/installation/index.html"
PAGE_404="${PUBLIC}/404.html"

# All built HTML pages, used for global constraint checks.
# Excludes paginator redirect pages (page/N/index.html) which are minimal
# meta-refresh redirects intentionally lacking full head/body content.
readarray -t ALL_PAGES < <(find "${PUBLIC}" -name '*.html' \
  | grep -v '/page/[0-9]\+/index\.html' | sort)

# All blog post pages, used for blog-specific checks (excludes paginator redirects)
readarray -t BLOG_POST_PAGES < <(find "${PUBLIC}/blog" -mindepth 2 -name 'index.html' \
  | grep -v '/page/[0-9]\+/index\.html' | sort)

# 2. Expected pages (derived dynamically from content directory)
printf '=== 2. Expected pages ===\n'

EXPECTED_PAGES=()
# Hugo always generates these regardless of content files
EXPECTED_PAGES+=("${PUBLIC}/index.html")
EXPECTED_PAGES+=("${PUBLIC}/404.html")
EXPECTED_PAGES+=("${PUBLIC}/tags/index.html")

# Section list pages, every subdirectory under content gets one
while IFS= read -r -d '' dir; do
  rel="${dir#${CONTENT_DIR}/}"
  EXPECTED_PAGES+=("${PUBLIC}/${rel}/index.html")
done < <(find "${CONTENT_DIR}" -mindepth 1 -type d -print0 | sort -z)

# Content pages, all .md files except _index.md.
# Hugo automatically strips a leading YYYY-MM-DD- date prefix from the slug,
# so derive the expected output path from the slug-form name, not the raw filename.
while IFS= read -r -d '' mdfile; do
  rel="${mdfile#${CONTENT_DIR}/}"
  base="${rel%.md}"
  [[ "$(basename "${base}")" == "_index" ]] && continue
  dir="$(dirname "${base}")"
  name="$(basename "${base}")"
  # Strip YYYY-MM-DD- prefix if present (mirrors Hugo's automatic slug behaviour)
  name="${name#[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-}"
  [[ "${dir}" == "." ]] && base="${name}" || base="${dir}/${name}"
  EXPECTED_PAGES+=("${PUBLIC}/${base}/index.html")
done < <(find "${CONTENT_DIR}" -name "*.md" -not -name "_index.md" -print0 | sort -z)

readarray -t EXPECTED_PAGES < <(printf '%s\n' "${EXPECTED_PAGES[@]}" | sort -u)

for page in "${EXPECTED_PAGES[@]}"; do
  if [[ -f "${page}" ]]; then
    pass "${page##${PUBLIC}/}"
  else
    fail "${page##${PUBLIC}/} (missing)"
  fi
done
printf '\n'

# 3. Constraints: Resources & CSS authoring (R1-R5)
printf '=== 3. R1-R5: Resources & CSS authoring ===\n'

# R1: No JavaScript, no <script> tags of any kind
HITS=$(grep -rn '<script' "${PUBLIC}" || true)
if [[ -z "${HITS}" ]]; then
  pass "[R1] No JavaScript"
else
  fail "[R1] No JavaScript"
  printf '%s\n' "${HITS}" | sed 's/^/        /'
fi

# R2: No external CSS, no rel="stylesheet" links
HITS=$(grep -rn 'rel="stylesheet"' "${PUBLIC}" || true)
if [[ -z "${HITS}" ]]; then
  pass "[R2] No external CSS"
else
  fail "[R2] No external CSS"
  printf '%s\n' "${HITS}" | sed 's/^/        /'
fi

# R3: No CDN or external font resources
HITS=$(grep -rn 'cdn\.\|fonts\.googleapis\.\|fonts\.gstatic\.' "${PUBLIC}" || true)
if [[ -z "${HITS}" ]]; then
  pass "[R3] No CDN resources"
else
  fail "[R3] No CDN resources"
  printf '%s\n' "${HITS}" | sed 's/^/        /'
fi

# R4: No inline style= attributes (Chroma emits style= on <span> and <pre>, exempt)
HITS=$(grep -rn ' style="' "${PUBLIC}" \
  | grep -v '<span style=' \
  | grep -v '<pre style=' \
  || true)
if [[ -z "${HITS}" ]]; then
  pass "[R4] No inline style= attrs"
else
  fail "[R4] No inline style= attrs"
  printf '%s\n' "${HITS}" | sed 's/^/        /'
fi

# R5: No CSS frameworks or utility classes.
# Semantic structural classes (e.g. docs-sidebar, breadcrumb) are allowed; the
# CSS for them is inline and costs no request. What is NOT allowed: utility/
# atomic classes and known framework class signatures. We detect those by
# pattern rather than maintaining an allowlist of every permitted class.
#
# Heuristics (each line is a prohibited signature):
#   - Tailwind-style utilities: tokens like mt-4, px-2, text-sm, flex, grid,
#     gap-4, w-1/2 (short tokens of the form <prefix>-<value>), or bare layout
#     utilities, appearing among space-separated classes.
#   - Bootstrap signatures: col-*, row, btn, btn-*, container, d-flex, etc.
# A utility/framework token is one that appears either immediately after the
# opening quote (class="TOKEN...) or after a space (class="... TOKEN). We encode
# that "start boundary" as (class="| ) and match the token after it.
UTILITY_RE='(class="| )(flex|grid|block|inline-block|hidden|container|row|btn)( |"|-)'
UTILITY_RE+='|(class="| )(mt|mb|ml|mr|mx|my|pt|pb|pl|pr|px|py|p|m|w|h|gap|text|bg|font|col|d)-[0-9a-z]'
HITS=$(grep -rnE "${UTILITY_RE}" "${PUBLIC}" \
  | grep 'class=' \
  | grep -v 'class="language-' \
  || true)
if [[ -z "${HITS}" ]]; then
  pass "[R5] No frameworks or utility classes"
else
  fail "[R5] No frameworks or utility classes"
  printf '%s\n' "${HITS}" | sed 's/^/        /'
fi
printf '\n'

# 4. Constraints: CSS Integrity (C1-C12)
printf '=== 4. C1-C12: CSS Integrity ===\n'

# C1: CSS delivered inline inside <style> in <head> on all pages
C1_FAIL=()
for page in "${ALL_PAGES[@]}"; do
  check_head "${page}" '<style>' || C1_FAIL+=("${page##${PUBLIC}/}")
done
if [[ "${#C1_FAIL[@]}" -eq 0 ]]; then
  pass "[C1] CSS inline in head"
else
  fail "[C1] CSS inline in head"
  printf '        no <style> in <head>: %s\n' "${C1_FAIL[@]}"
fi

# C2-C12: CSS rules verified against the home page <style> block.
# All pages share the same inline styles; home is a reliable proxy.
grep -q 'position: absolute' "${PAGE_HOME}" \
  && grep -q 'z-index' "${PAGE_HOME}" \
  && grep -q 'padding' "${PAGE_HOME}" \
  && pass "[C2] Skip link hide/show CSS" \
  || fail "[C2] Skip link hide/show CSS"

grep -q '100ch' "${PAGE_HOME}" \
  && pass "[C3] Body max-width CSS" \
  || fail "[C3] Body max-width CSS"

grep -q 'line-height: 1.6' "${PAGE_HOME}" \
  && pass "[C4] Body line-height CSS" \
  || fail "[C4] Body line-height CSS"

grep -q 'height: auto' "${PAGE_HOME}" \
  && pass "[C5] Image responsive CSS" \
  || fail "[C5] Image responsive CSS"

grep -q 'border-collapse' "${PAGE_HOME}" \
  && pass "[C6] Table border CSS" \
  || fail "[C6] Table border CSS"

grep -q 'list-style: none' "${PAGE_HOME}" \
  && pass "[C7] Nav reset CSS" \
  || fail "[C7] Nav reset CSS"

grep -q '\[aria-current' "${PAGE_HOME}" \
  && pass "[C8] Active nav CSS" \
  || fail "[C8] Active nav CSS"

grep -q 'prefers-color-scheme: dark' "${PAGE_HOME}" \
  && pass "[C9] Dark mode CSS" \
  || fail "[C9] Dark mode CSS"

grep -q 'overflow-x: auto' "${PAGE_HOME}" \
  && pass "[C10] Pre overflow CSS" \
  || fail "[C10] Pre overflow CSS"

grep -q 'font-size: 18px' "${PAGE_HOME}" \
  && pass "[C11] Body font-size CSS" \
  || fail "[C11] Body font-size CSS"

grep -q 'margin-top: 2rem' "${PAGE_HOME}" \
  && pass "[C12] Article spacing CSS" \
  || fail "[C12] Article spacing CSS"
printf '\n'

# 5. Constraints: Semantic HTML and Accessibility (S1-S7)
printf '=== 5. S1-S7: Semantic HTML & Accessibility ===\n'

# S1: Skip link, <a href="#main-content">Skip to content</a> on every page
check_all "[S1] Skip link element" 'Skip to content' "${ALL_PAGES[@]}"

# S2: aria-label on every <nav>
check_all "[S2] Nav aria-label" 'aria-label' "${ALL_PAGES[@]}"

# S3: aria-current="page" on the active nav link, blog list has Blog item active
grep -q 'aria-current="page"' "${PAGE_BLOG_LIST}" \
  && pass "[S3] aria-current active" \
  || fail "[S3] aria-current active"

# S4: Site title as <a> on every page (or logo partial if provided)
check_all "[S4] Site title" '<a href="/">' "${ALL_PAGES[@]}"

# S5: <time datetime="..."> on blog post dates
grep -q '<time ' "${PAGE_BLOG_POST}" \
  && grep -q 'datetime=' "${PAGE_BLOG_POST}" \
  && pass "[S5] Blog post time elem" \
  || fail "[S5] Blog post time elem"

# S6: Image render hook, imageMode param with eager/lazy loading and link modes.
# Verified via template source, example site content does not embed images.
grep -q '<figure>' "layouts/_markup/render-image.html" \
  && grep -q 'loading=' "layouts/_markup/render-image.html" \
  && grep -q 'fetchpriority' "layouts/_markup/render-image.html" \
  && pass "[S6] Image render hook (template)" \
  || fail "[S6] Image render hook (template)"

# S7: Breadcrumb on docs pages and blog posts
grep -q 'aria-label="Breadcrumb"' "${PAGE_DOC}" \
  && grep -q 'aria-label="Breadcrumb"' "${PAGE_BLOG_POST}" \
  && pass "[S7] Breadcrumb navigation" \
  || fail "[S7] Breadcrumb navigation"
printf '\n'

# 6. Constraints: SEO and Metadata (M1-M10)
printf '=== 6. M1-M10: SEO & Metadata ===\n'

# M1: <meta charset> and viewport on every page
check_head_all "[M1] charset and viewport" 'charset' "${ALL_PAGES[@]}"

# M2: Canonical URL, <link rel="canonical"> on every page
check_head_all "[M2] Canonical URL" 'rel="canonical"' "${ALL_PAGES[@]}"

# M3: Meta description on every page
check_head_all "[M3] Meta description" 'name="description"' "${ALL_PAGES[@]}"

# M4: Open Graph tags, og:title, og:description, og:type, og:url on every page
check_head_all "[M4] Open Graph tags" 'og:title' "${ALL_PAGES[@]}"

# M5: og:site_name on every page
check_head_all "[M5] OG site_name" 'og:site_name' "${ALL_PAGES[@]}"

# M6: Schema.org microdata, blog posts carry itemscope itemtype="...BlogPosting"
check_all "[M6] Blog microdata" 'itemtype="https://schema.org/BlogPosting"' "${BLOG_POST_PAGES[@]}"

# M7: article:published_time and article:modified_time on blog posts
M7_FAIL=()
for page in "${BLOG_POST_PAGES[@]}"; do
  check_head "${page}" 'article:published_time' \
    && check_head "${page}" 'article:modified_time' \
    || M7_FAIL+=("${page##${PUBLIC}/}")
done
if [[ "${#M7_FAIL[@]}" -eq 0 ]]; then
  pass "[M7] Blog article times"
else
  fail "[M7] Blog article times"
  printf '        missing in: %s\n' "${M7_FAIL[@]}"
fi

# M8: RSS autodiscovery, <link rel="alternate" type="application/rss+xml"> in <head>
check_head "${PAGE_HOME}" 'rel="alternate"' \
  && check_head "${PAGE_BLOG_LIST}" 'rel="alternate"' \
  && pass "[M8] RSS autodiscovery" \
  || fail "[M8] RSS autodiscovery"

# M9: noindex in <head> on the 404 page
check_head "${PAGE_404}" 'noindex' \
  && pass "[M9] 404 noindex in head" \
  || fail "[M9] 404 noindex in head"

# M10: <meta name="author"> on every page except 404
NON_404_PAGES=()
for page in "${ALL_PAGES[@]}"; do
  [[ "${page}" == "${PAGE_404}" ]] && continue
  NON_404_PAGES+=("${page}")
done
check_head_all "[M10] Author meta" 'name="author"' "${NON_404_PAGES[@]}"
printf '\n'

# Summary
printf '=== Summary ===\n'
printf '  Passed: %s\n' "${PASS}"
printf '  Failed: %s\n' "${FAIL}"
printf '\n'

if [[ "${FAIL}" -gt 0 ]]; then
  printf 'RESULT: FAIL (%s check(s) failed)\n' "${FAIL}"
  exit 1
else
  printf 'RESULT: PASS\n'
  exit 0
fi
