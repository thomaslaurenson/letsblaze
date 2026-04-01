#!/usr/bin/env bash
# letsblaze test suite
# Builds the exampleSite and verifies all constraints and key features.
# Exit code 0 = all checks passed. Exit code 1 = one or more failures.

set -euo pipefail

THEME="letsblaze"
SITE_DIR="exampleSite"
PUBLIC="${SITE_DIR}/public"
HUGO_FLAGS="--themesDir ../.. --theme ${THEME}"

PASS=0
FAIL=0

pass() { echo "  PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL  $1"; FAIL=$((FAIL + 1)); }

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
echo "=== Build ==="
rm -rf "${PUBLIC}"
if ! (cd "${SITE_DIR}" && hugo ${HUGO_FLAGS} 2>&1); then
    echo "  ERROR: hugo build failed — aborting tests"
    exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Expected pages
# ---------------------------------------------------------------------------
echo "=== Expected pages ==="
EXPECTED_PAGES=(
    "${PUBLIC}/404.html"
    "${PUBLIC}/about/index.html"
    "${PUBLIC}/blog/hello-world/index.html"
    "${PUBLIC}/blog/index.html"
    "${PUBLIC}/blog/second-post/index.html"
    "${PUBLIC}/docs/getting-started/configuration/index.html"
    "${PUBLIC}/docs/getting-started/index.html"
    "${PUBLIC}/docs/getting-started/installation/index.html"
    "${PUBLIC}/docs/index.html"
    "${PUBLIC}/docs/reference/index.html"
    "${PUBLIC}/index.html"
    "${PUBLIC}/tags/example/index.html"
    "${PUBLIC}/tags/hello/index.html"
    "${PUBLIC}/tags/index.html"
)
for page in "${EXPECTED_PAGES[@]}"; do
    if [[ -f "${page}" ]]; then
        pass "${page}"
    else
        fail "${page} (missing)"
    fi
done
echo ""

# ---------------------------------------------------------------------------
# Hard constraints — must all be 0 violations
# ---------------------------------------------------------------------------
echo "=== Constraint checks (must all be 0) ==="

COUNT=$(grep -rc '<script' "${PUBLIC}" | grep -v ':0' | wc -l || true)
if [[ "${COUNT}" -eq 0 ]]; then
    pass "No <script> tags"
else
    fail "<script> tags found in ${COUNT} file(s)"
    grep -rn '<script' "${PUBLIC}" || true
fi

COUNT=$(grep -rc 'rel="stylesheet"' "${PUBLIC}" | grep -v ':0' | wc -l || true)
if [[ "${COUNT}" -eq 0 ]]; then
    pass "No external stylesheets"
else
    fail "External stylesheets found in ${COUNT} file(s)"
    grep -rn 'rel="stylesheet"' "${PUBLIC}" || true
fi

COUNT=$(grep -rc 'cdn\.\|fonts\.googleapis\|fonts\.gstatic' "${PUBLIC}" | grep -v ':0' | wc -l || true)
if [[ "${COUNT}" -eq 0 ]]; then
    pass "No CDN or external font resources"
else
    fail "CDN/external resources found in ${COUNT} file(s)"
    grep -rn 'cdn\.\|fonts\.googleapis\|fonts\.gstatic' "${PUBLIC}" || true
fi

# class= check — Chroma emits class="highlight" and class="language-*"; these are expected.
# The skip link uses class="skip-link" — intentional, required for CSS hide/reveal targeting.
# Hugo's Goldmark renderer emits footnote classes (footnote-ref, footnotes, footnote-backref).
# Any class on structural elements (nav, header, footer, ul, li, a, h1-h6, p, main) from
# THEME TEMPLATES is a violation.
echo ""
echo "=== class= audit (Chroma, skip-link, and Goldmark footnote classes are expected) ==="
CLASS_HITS=$(grep -rn 'class="' "${PUBLIC}" || true)
if [[ -z "${CLASS_HITS}" ]]; then
    pass "No class= attributes anywhere"
else
    # Filter out all known-good classes
    BAD_CLASSES=$(echo "${CLASS_HITS}" \
        | grep -v 'class="highlight"' \
        | grep -v 'class="language-' \
        | grep -v 'class="skip-link"' \
        | grep -v 'class="footnote-ref"' \
        | grep -v 'class="footnotes"' \
        | grep -v 'class="footnote-backref"' \
        || true)
    if [[ -z "${BAD_CLASSES}" ]]; then
        pass "class= attributes present but all are expected (Chroma, skip-link, Goldmark footnotes)"
        echo "      Hits by category:"
        echo "${CLASS_HITS}" | grep -c 'class="skip-link"' | xargs -I{} echo "        skip-link: {} occurrence(s)"
        echo "${CLASS_HITS}" | grep -c 'class="highlight"\|class="language-' | xargs -I{} echo "        Chroma:     {} occurrence(s)" || true
        echo "${CLASS_HITS}" | grep -c 'class="footnote' | xargs -I{} echo "        Goldmark:   {} occurrence(s)" || true
    else
        fail "Unexpected class= attributes found — review these lines:"
        echo "${BAD_CLASSES}" | sed 's/^/        /'
    fi
fi
echo ""

# ---------------------------------------------------------------------------
# Feature spot-checks
# ---------------------------------------------------------------------------
echo "=== Feature checks ==="

grep -q 'prefers-color-scheme' "${PUBLIC}/index.html" \
    && pass "Dark mode block in <head>" \
    || fail "No prefers-color-scheme found in index.html"

grep -q 'Skip to content' "${PUBLIC}/index.html" \
    && pass "Skip link present" \
    || fail "Skip link missing from index.html"

grep -q 'aria-label' "${PUBLIC}/index.html" \
    && pass "aria-label present in index.html" \
    || fail "No aria-label found in index.html"

grep -q '<link rel="canonical"' "${PUBLIC}/index.html" \
    && pass "Canonical URL in <head>" \
    || fail "Canonical URL missing from index.html"

grep -q 'og:title' "${PUBLIC}/index.html" \
    && pass "OG meta tags in <head>" \
    || fail "OG meta tags missing from index.html"

grep -q 'newer posts\|older posts' "${PUBLIC}/blog/index.html" \
    && pass "Pagination nav on blog index" \
    || { echo "  INFO  Pagination nav absent from blog/index.html (expected if post count < pagerSize)"; PASS=$((PASS + 1)); }

grep -q 'prev\|next' "${PUBLIC}/blog/hello-world/index.html" \
    && pass "Prev/next nav on blog post" \
    || fail "Prev/next nav missing from blog/hello-world/index.html"

grep -q '<details' "${PUBLIC}/docs/getting-started/installation/index.html" \
    && pass "Collapsible nav (<details>) in docs page" \
    || fail "<details> missing from docs/getting-started/installation/index.html"

grep -q 'overflow-x' "${PUBLIC}/index.html" \
    && pass "Table overflow-x rule present" \
    || fail "overflow-x rule missing (check baseof.html <style>)"

grep -q 'noindex' "${PUBLIC}/404.html" \
    && pass "404 has noindex robots meta" \
    || fail "404 is missing noindex robots meta"

grep -q '<time ' "${PUBLIC}/blog/hello-world/index.html" \
    && pass "<time> element on blog post" \
    || fail "<time> element missing from blog post"

grep -q 'aria-current="page"' "${PUBLIC}/docs/getting-started/installation/index.html" \
    && pass "aria-current=page in docs sidebar" \
    || fail "aria-current=page missing from docs sidebar"
echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "=== Summary ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""

if [[ "${FAIL}" -gt 0 ]]; then
    echo "RESULT: FAIL (${FAIL} check(s) failed)"
    exit 1
else
    echo "RESULT: PASS"
    exit 0
fi
