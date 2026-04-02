# letsblaze

Blazingly fast, highly opinionated flyweight Hugo theme

## Philosophy

letsblaze is built around one principle: **the fastest resource is one that was never requested.**

- :no_entry: No JavaScript
- :link: No external stylesheets
- :pencil2: No web fonts
- :cloud: No CDN calls
- :rocket: Plain HTML with a single inline `<style>`

## Constraints

Every design decision is governed by a numbered constraint. These identifiers are used in
`scripts/test.sh` so test failures trace directly to this document.

Constraints are grouped by category with a category prefix:
**R** = External Resources, **C** = CSS Integrity, **S** = Semantic HTML, **M** = SEO & Metadata

### External Resources

| ID | Constraint |
|----|------------|
| R1 | **No JavaScript** — no `<script>` tags of any kind |
| R2 | **No external CSS** — no `rel="stylesheet"` links |
| R3 | **No CDN resources** — no cdn., fonts.googleapis, or fonts.gstatic URLs |
| R4 | **No inline `style=`** — no `style=` attributes on HTML elements (Chroma `<span>` and `<pre>` are exempt) |
| R5 | **No structural classes** — no `class=` on structural elements (allowlist: `.skip-link`, Chroma classes, Goldmark footnote classes) |

### CSS Integrity

All CSS is inline inside a `<style>` block in `<head>`, in `layouts/_partials/head-styles.html`.
Every rule has an explicit justification.

| ID  | Constraint | Justification |
|-----|------------|---------------|
| C1  | **CSS inline in `<head>`** | No linked file = no extra HTTP request, no render blocking, no FOUC |
| C2  | **Skip link hidden off-screen** | `position: absolute; left: -9999px` — revealed on `:focus` only |
| C3  | **`body { max-width: 100ch }`** | Prevents unreadable line lengths on wide viewports |
| C4  | **`body { line-height: 1.6 }`** | Browser default is too tight for comfortable reading |
| C5  | **`img { max-width: 100%; height: auto }`** | Responsive images; `height: auto` prevents CLS alongside explicit `width`/`height` attributes |
| C6  | **`table { border-collapse: collapse }`** | Readable table borders without external classes |
| C7  | **`nav ul { list-style: none }`** | Removes browser bullet and indent defaults from all nav lists |
| C8  | **`[aria-current="page"] { font-weight: bold }`** | Active-link indicator without a class |
| C9  | **Dark mode via `prefers-color-scheme: dark`** | Follows OS preference — no JavaScript, no toggle, no cookie |
| C10 | **`pre { overflow-x: auto }`** | Wide code blocks scroll horizontally instead of being clipped |

### Semantic HTML and Accessibility

| ID | Constraint |
|----|------------|
| S1 | **Skip link** — `<a href="#main-content">Skip to content</a>` on every page |
| S2 | **`aria-label` on every `<nav>`** |
| S3 | **`aria-current="page"` on the active nav link** |
| S4 | **Site title as `<h1>`** on every page |
| S5 | **`<time datetime="...">`** on blog post dates |
| S6 | **`<figure>` with `loading="lazy"`** for all images |
| S7 | **`<details>`/`<summary>`** for docs sidebar navigation — no JavaScript required |

### SEO and Metadata

| ID  | Constraint |
|-----|------------|
| M1  | **`<meta charset>` and viewport** on every page |
| M2  | **Canonical URL** — `<link rel="canonical">` on every page |
| M3  | **Meta description** — falls back through page description → summary → site description |
| M4  | **Open Graph tags** — `og:title`, `og:description`, `og:type`, `og:url` on every page |
| M5  | **`og:site_name`** on every page |
| M6  | **Schema.org microdata** — blog posts carry `itemscope itemtype="...BlogPosting"` (no `<script>` required) |
| M7  | **`article:published_time` and `article:modified_time`** on blog posts |
| M8  | **RSS autodiscovery** — `<link rel="alternate" type="application/rss+xml">` in `<head>` on pages with feeds |
| M9  | **`noindex` in `<head>`** on the 404 page |
| M10 | **`<meta name="author">`** on every page |
