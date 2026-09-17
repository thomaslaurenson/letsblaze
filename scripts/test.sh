#!/usr/bin/env bash
# letsblaze test suite
# Builds the exampleSite and verifies all constraints defined in README.md.
# Constraint IDs match README.md: R (Resources & CSS authoring), C (CSS
# integrity), S (Semantic HTML), M (SEO & Metadata).
# Exit code 0 = all checks passed. Exit code 1 = one or more failures.

set -euo pipefail

die() { printf '[!] %s\n' "$*" >&2; exit 1; }

readonly THEME="letsblaze"
readonly SITE_DIR="exampleSite"
readonly CONTENT_DIR="${SITE_DIR}/content"
readonly PUBLIC="${SITE_DIR}/public"
readonly HUGO_FLAGS=(--themesDir ../.. --theme "${THEME}")
# The deploy workflow ships a minified build, so the resource checks run over
# one of those too. The other checks match on whitespace and use the plain build.
PUBLIC_MIN="$(mktemp -d)"
readonly PUBLIC_MIN
trap 'rm -rf -- "${PUBLIC_MIN}"' EXIT

# Running totals, updated by pass and fail
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
  local page failures=()
  for page in "$@"; do
    grep -q "${pattern}" "${page}" 2>/dev/null || failures+=("${page##"${PUBLIC}"/}")
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
  local page failures=()
  for page in "$@"; do
    check_head "${page}" "${pattern}" 2>/dev/null || failures+=("${page##"${PUBLIC}"/}")
  done
  if [[ "${#failures[@]}" -eq 0 ]]; then
    pass "${label}"
  else
    fail "${label}"
    printf '        missing in: %s\n' "${failures[@]}"
  fi
}

# Check that one file matches every pattern given.
#
# Arguments:
#   $1 - Label for the test output
#   $2 - File to search
#   $@ - Patterns that must all match (passed to grep -q, after shift 2)
# Outputs:
#   stdout: PASS or FAIL line, with the first missing pattern on failure
check_file() {
  local label="${1}" file="${2}"
  shift 2
  local pattern
  for pattern in "$@"; do
    if ! grep -q "${pattern}" "${file}" 2>/dev/null; then
      fail "${label}"
      printf '        missing in %s: %s\n' "${file##"${PUBLIC}"/}" "${pattern}"
      return
    fi
  done
  pass "${label}"
}

# Check that the inline style block contains every CSS fragment given.
#
# Arguments:
#   $1 - Label for the test output
#   $@ - Fixed-string fragments that must all appear (after shift 1)
# Globals:
#   STYLE - the <style> block of the home page, read only
# Outputs:
#   stdout: PASS or FAIL line, with the first missing fragment on failure
check_style() {
  local label="${1}"
  shift
  local fragment
  for fragment in "$@"; do
    if ! grep -qF -- "${fragment}" <<< "${STYLE}"; then
      fail "${label}"
      printf '        missing rule: %s\n' "${fragment}"
      return
    fi
  done
  pass "${label}"
}

# Report a check that passes only when it produced no hits.
#
# Arguments:
#   $1 - Label for the test output
#   $2 - Offending lines, empty when the check passed
# Outputs:
#   stdout: PASS or FAIL line, with the hits indented on failure
report_hits() {
  local label="${1}" hits="${2}"
  if [[ -z "${hits}" ]]; then
    pass "${label}"
  else
    fail "${label}"
    printf '%s\n' "${hits}" | sed 's/^/        /'
  fi
}

main() {
  local page

  # 1. Build
  printf '=== 1. Build ===\n'
  rm -rf "${PUBLIC}"
  (cd "${SITE_DIR}" && hugo "${HUGO_FLAGS[@]}" 2>&1) \
    || die "hugo build failed, aborting tests"
  (cd "${SITE_DIR}" && hugo "${HUGO_FLAGS[@]}" --minify --quiet -d "${PUBLIC_MIN}" 2>&1) \
    || die "minified hugo build failed, aborting tests"
  printf '\n'

  # Page sets used by constraint checks
  local page_home="${PUBLIC}/index.html"
  local page_blog_list="${PUBLIC}/blog/index.html"
  local page_blog_post="${PUBLIC}/blog/welcome-to-letsblaze/index.html"
  local page_doc="${PUBLIC}/docs/getting-started/installation/index.html"
  local page_markdown="${PUBLIC}/docs/reference/markdown/index.html"
  local page_404="${PUBLIC}/404.html"

  # All built HTML pages, used for global constraint checks.
  # Excludes paginator redirect pages (page/N/index.html) which are minimal
  # meta-refresh redirects intentionally lacking full head/body content.
  local all_pages
  readarray -t all_pages < <(find "${PUBLIC}" -name '*.html' \
    | grep -v '/page/[0-9]\+/index\.html' | sort)

  # All blog post pages, used for blog-specific checks (excludes paginator redirects)
  local blog_post_pages
  readarray -t blog_post_pages < <(find "${PUBLIC}/blog" -mindepth 2 -name 'index.html' \
    | grep -v '/page/[0-9]\+/index\.html' | sort)

  # 2. Expected pages (derived dynamically from content directory)
  printf '=== 2. Expected pages ===\n'

  local expected_pages=() dir rel mdfile base name
  # Hugo always generates these regardless of content files
  expected_pages+=("${PUBLIC}/index.html")
  expected_pages+=("${PUBLIC}/404.html")
  expected_pages+=("${PUBLIC}/tags/index.html")

  # Section list pages, every subdirectory under content gets one
  while IFS= read -r -d '' dir; do
    rel="${dir#"${CONTENT_DIR}"/}"
    expected_pages+=("${PUBLIC}/${rel}/index.html")
  done < <(find "${CONTENT_DIR}" -mindepth 1 -type d -print0 | sort -z)

  # Content pages, all .md files except _index.md.
  # The example config sets frontmatter.date = [":filename", ":default"], so Hugo
  # takes a YYYY-MM-DD- filename prefix as the date and the remainder as the slug.
  # Derive the expected output path the same way.
  while IFS= read -r -d '' mdfile; do
    rel="${mdfile#"${CONTENT_DIR}"/}"
    base="${rel%.md}"
    [[ "$(basename "${base}")" == "_index" ]] && continue
    dir="$(dirname "${base}")"
    name="$(basename "${base}")"
    # Strip YYYY-MM-DD- prefix if present (mirrors the :filename handling)
    name="${name#[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-}"
    if [[ "${dir}" == "." ]]; then
      base="${name}"
    else
      base="${dir}/${name}"
    fi
    expected_pages+=("${PUBLIC}/${base}/index.html")
  done < <(find "${CONTENT_DIR}" -name "*.md" -not -name "_index.md" -print0 | sort -z)

  readarray -t expected_pages < <(printf '%s\n' "${expected_pages[@]}" | sort -u)

  for page in "${expected_pages[@]}"; do
    if [[ -f "${page}" ]]; then
      pass "${page##"${PUBLIC}"/}"
    else
      fail "${page##"${PUBLIC}"/} (missing)"
    fi
  done
  printf '\n'

  # 3. Constraints: Resources & CSS authoring (R1-R5), over both builds
  printf '=== 3. R1-R5: Resources & CSS authoring ===\n'
  local builds=("${PUBLIC}" "${PUBLIC_MIN}")
  local hits

  # R1: No JavaScript, no <script> tags of any kind
  hits=$(grep -rn '<script' "${builds[@]}" || true)
  report_hits "[R1] No JavaScript" "${hits}"

  # R2: No external CSS, no rel="stylesheet" links
  hits=$(grep -rn 'rel="stylesheet"' "${builds[@]}" || true)
  report_hits "[R2] No external CSS" "${hits}"

  # R3: No CDN or external font resources
  hits=$(grep -rn 'cdn\.\|fonts\.googleapis\.\|fonts\.gstatic\.' "${builds[@]}" || true)
  report_hits "[R3] No CDN resources" "${hits}"

  # R4: No inline style= attributes. Chroma emits style= on its <span> and <pre>
  # elements, so those two tags are exempt. Each opening tag is matched on its
  # own, so a span on the same line cannot hide another element's style=.
  hits=$(grep -rnoE '<[a-zA-Z]+[^>]*\bstyle="' "${builds[@]}" \
    | grep -vE ':<(span|pre)[ >]' \
    || true)
  report_hits "[R4] No inline style= attrs" "${hits}"

  # R5: No CSS frameworks or utility classes.
  # Semantic structural classes (e.g. post-meta, table-wrap) are allowed; the
  # CSS for them is inline and costs no request. What is NOT allowed: utility/
  # atomic classes and known framework class signatures. We detect those by
  # pattern rather than maintaining an allowlist of every permitted class.
  #
  # Every class attribute is reduced to its tokens first, whether quoted or not
  # (the minifier drops the quotes), so each token is judged on its own and prose
  # sharing a line with a class attribute can never match. Attributes escaped
  # inside code samples start with &#34; and are skipped.
  #
  # Heuristics (each alternative is a prohibited signature):
  #   - Tailwind-style utilities: tokens like mt-4, px-2, text-sm, gap-4, w-1/2
  #     (short tokens of the form <prefix>-<value>), or bare layout utilities
  #     such as flex, grid, block, hidden.
  #   - Bootstrap signatures: col-*, row, btn, btn-*, container, d-flex, etc.
  local class_tokens utility_re
  class_tokens="$(grep -rhoE 'class=("[^"]*"|[A-Za-z][^ >]*)' "${builds[@]}" \
    | sed -E 's/^class=//; s/"//g' | tr ' ' '\n' | sort -u)"
  utility_re='^(flex|grid|block|inline-block|hidden|container|row|btn)($|-)'
  utility_re+='|^(mt|mb|ml|mr|mx|my|pt|pb|pl|pr|px|py|p|m|w|h|gap|text|bg|font|col|d)-[0-9a-z]'
  hits=$(grep -E "${utility_re}" <<< "${class_tokens}" || true)
  report_hits "[R5] No frameworks or utility classes" "${hits}"
  printf '\n'

  # 4. Constraints: CSS Integrity (C1-C19)
  printf '=== 4. C1-C19: CSS Integrity ===\n'

  # C1: CSS delivered inline inside <style> in <head> on all pages
  check_head_all "[C1] CSS inline in head" '<style>' "${all_pages[@]}"

  # C2-C15: CSS rules verified against the <style> block alone, so markup or
  # content elsewhere on the page cannot satisfy a check. All pages share the
  # same inline styles; home is a reliable proxy.
  STYLE="$(awk '/<style>/,/<\/style>/' "${page_home}")"
  readonly STYLE

  check_style "[C2] Skip link hide/show CSS" \
    '.skip-link { position: absolute; left: -9999px;' \
    '.skip-link:focus { left: 0; z-index: 1; background: #fff; padding:'
  check_style "[C3] Body max-width CSS" 'body { max-width: 100ch;'
  check_style "[C4] Body line-height CSS" 'line-height: 1.6;'
  check_style "[C5] Image responsive CSS" 'img { max-width: 100%; height: auto; }'
  check_style "[C6] Table border CSS" \
    'table { border-collapse: collapse; }' \
    '.table-wrap { overflow-x: auto; }'
  check_file "[C6] Table wrapper emitted" "${page_markdown}" '<div class="table-wrap">'
  check_style "[C7] Nav reset CSS" \
    'nav ul { list-style: none; margin: 0; padding: 0; }' \
    'nav[aria-label="Breadcrumb"] ol { list-style: none; margin: 0; padding: 0; }'
  check_style "[C8] Active nav CSS" '[aria-current="page"] { font-weight: bold; }'
  check_style "[C9] Dark mode CSS" '@media (prefers-color-scheme: dark)'
  check_style "[C10] Pre overflow CSS" 'pre { overflow-x: auto; }'
  check_style "[C11] Body font-size CSS" 'font-size: 18px;'
  check_style "[C13] Math block overflow CSS" 'math[display="block"] { display: block; overflow-x: auto;'
  check_style "[C14] Inline nav items CSS" \
    'header nav ul li { display: inline; }' \
    'nav[aria-label="Breadcrumb"] ol li { display: inline; }' \
    'nav[aria-label="Tags"] ul li { display: inline; }'
  check_style "[C15] Colour scheme CSS" ':root { color-scheme: light dark; }'
  check_style "[C16] Table cell CSS" 'th, td { border: 1px solid; padding: 0.4rem 0.8rem; }'
  check_style "[C17] Table alignment CSS" \
    '[data-align="left"]' '[data-align="center"]' '[data-align="right"]'
  check_file "[C17] Table hook emits data-align" "${page_markdown}" 'data-align="'
  check_style "[C18] Nav separator CSS" \
    'header nav ul li + li::before { content: " / " / ""; }' \
    'nav[aria-label="Breadcrumb"] ol li + li::before { content: " \203A " / ""; }'
  check_style "[C19] Post metadata grid CSS" \
    '.post-meta { display: grid;' '.post-meta dt { font-weight: bold; }'

  # Math renders to native MathML at build time (render-passthrough.html + the
  # passthrough delimiters in exampleSite/hugo.toml). This also gives the R1/R4/R5
  # resource checks real math output to police, guarding against a regression that
  # leaves raw LaTeX in the page or reintroduces a scripted/styled math renderer.
  check_file "[C13] Math renders to MathML" "${page_markdown}" '<math'
  printf '\n'

  # 5. Constraints: Semantic HTML and Accessibility (S1-S7)
  printf '=== 5. S1-S7: Semantic HTML & Accessibility ===\n'

  # S1: Skip link, <a href="#main-content">Skip to content</a> on every page
  check_all "[S1] Skip link element" 'Skip to content' "${all_pages[@]}"

  # S2: aria-label on every <nav>, checked per element rather than once per page.
  # The inverted match is captured rather than tested with -q because ugrep, which
  # some systems install as grep, returns 1 from "grep -qv" even when a line matches.
  local unlabelled s2_fail=()
  for page in "${all_pages[@]}"; do
    unlabelled="$(grep -o '<nav[^>]*>' "${page}" | grep -v 'aria-label=' || true)"
    if [[ -n "${unlabelled}" ]]; then
      s2_fail+=("${page##"${PUBLIC}"/}")
    fi
  done
  if [[ "${#s2_fail[@]}" -eq 0 ]]; then
    pass "[S2] Nav aria-label"
  else
    fail "[S2] Nav aria-label"
    printf '        unlabelled nav in: %s\n' "${s2_fail[@]}"
  fi

  # S3: aria-current="page" on the active nav link, blog list has Blog item active
  check_file "[S3] aria-current active" "${page_blog_list}" 'aria-current="page"'

  # S4: Site title as <a> on every page (or logo partial if provided)
  check_all "[S4] Site title" '<a href="/">' "${all_pages[@]}"

  # S5: <time datetime="..."> on blog post dates
  check_file "[S5] Blog post time elem" "${page_blog_post}" '<time ' 'datetime='

  # S6: Image render hook, imageMode param with eager/lazy loading and link modes.
  # Verified via template source: the example site's image syntax sits inside
  # code fences, so no built page embeds an image.
  check_file "[S6] Image render hook (template)" "layouts/_markup/render-image.html" \
    '<figure>' 'loading=' 'fetchpriority'

  # S7: Breadcrumb on docs pages and blog posts
  check_all "[S7] Breadcrumb navigation" 'aria-label="Breadcrumb"' "${page_doc}" "${page_blog_post}"
  printf '\n'

  # 6. Constraints: SEO and Metadata (M1-M10)
  printf '=== 6. M1-M10: SEO & Metadata ===\n'

  # M1: <meta charset> and viewport on every page
  check_head_all "[M1] charset" '<meta charset=' "${all_pages[@]}"
  check_head_all "[M1] viewport" 'name="viewport"' "${all_pages[@]}"

  # M2: Canonical URL, <link rel="canonical"> on every page
  check_head_all "[M2] Canonical URL" 'rel="canonical"' "${all_pages[@]}"

  # M3: Meta description on every page
  check_head_all "[M3] Meta description" 'name="description"' "${all_pages[@]}"

  # M4: Open Graph tags, og:title, og:description, og:type, og:url on every page
  check_head_all "[M4] Open Graph tags" 'og:title' "${all_pages[@]}"

  # M5: og:site_name on every page
  check_head_all "[M5] OG site_name" 'og:site_name' "${all_pages[@]}"

  # M6: Schema.org microdata, blog posts carry itemscope itemtype="...BlogPosting"
  check_all "[M6] Blog microdata" 'itemtype="https://schema.org/BlogPosting"' "${blog_post_pages[@]}"

  # M7: article:published_time and article:modified_time on blog posts
  check_head_all "[M7] Blog published time" 'article:published_time' "${blog_post_pages[@]}"
  check_head_all "[M7] Blog modified time" 'article:modified_time' "${blog_post_pages[@]}"

  # M8: RSS autodiscovery, <link rel="alternate" type="application/rss+xml"> in <head>
  check_head_all "[M8] RSS autodiscovery" 'rel="alternate"' "${page_home}" "${page_blog_list}"

  # M9: noindex in <head> on the 404 page
  check_head_all "[M9] 404 noindex in head" 'noindex' "${page_404}"

  # M10: <meta name="author"> on every page except 404
  local non_404_pages=()
  for page in "${all_pages[@]}"; do
    [[ "${page}" == "${page_404}" ]] && continue
    non_404_pages+=("${page}")
  done
  check_head_all "[M10] Author meta" 'name="author"' "${non_404_pages[@]}"
  printf '\n'

  # Summary
  printf '=== Summary ===\n'
  printf '  Passed: %s\n' "${PASS}"
  printf '  Failed: %s\n' "${FAIL}"
  printf '\n'

  if [[ "${FAIL}" -gt 0 ]]; then
    printf 'RESULT: FAIL (%s check(s) failed)\n' "${FAIL}"
    exit 1
  fi
  printf 'RESULT: PASS\n'
}

main "$@"
