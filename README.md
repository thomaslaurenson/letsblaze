# letsblaze

Blazingly fast, highly opinionated flyweight Hugo theme

## Philosophy

letsblaze is built around one principle: **the fastest resource is one that was never requested.**

- :no_entry: No JavaScript
- :link: No external stylesheets
- :pencil2: No web fonts
- :cloud: No CDN calls
- :rocket: Plain HTML with a single inline `<style>`

## Installation

letsblaze requires Hugo **0.134.0 or later**.

### Option 1 — Git submodule (recommended)

Add letsblaze and a git submodule:

```bash
git submodule add https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

Then set the theme in your `hugo.toml`:

```toml
theme = "letsblaze"
```

To update the theme later:

```bash
git submodule update --remote themes/letsblaze
```

### Option 2 — Manual clone

This method is beginner-friendly and has no Git dependency management.

```bash
git clone https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

Then set the theme in your `hugo.toml`:

```toml
theme = "letsblaze"
```

To update, delete the folder and clone again, or pull updates:

```bash
git pull
```

### Option 3 — Hugo Modules

Requires Go to be installed. Then use `hugo mod` command to add letsblaze theme:

```bash
hugo mod get github.com/thomaslaurenson/letsblaze
```

Then set the theme in your `hugo.toml`:

```toml
[module]
  [[module.imports]]
    path = "github.com/thomaslaurenson/letsblaze"
```

### Logo (optional)

To use a custom logo instead of the plain text site title, create `layouts/partials/logo.html` in your site (not in the theme). Inline SVG is recommended — it requires no extra HTTP request and stays consistent with the theme's no-external-resources philosophy.

Example `layouts/partials/logo.html`:

```html
<a href="/">
  <svg xmlns="http://www.w3.org/2000/svg" width="120" height="32" aria-label="{{ .Site.Title }}">
    <!-- your SVG content here -->
  </svg>
</a>
```

## Constraints

Every design decision is governed by a numbered constraint. These identifiers are used in `scripts/test.sh` so test failures trace directly to this document.

Constraints are grouped by category with a category prefix:

- **R**: External Resources
- **C**: CSS Integrity
- **S**: Semantic HTML
- **M**: SEO & Metadata

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
| C11 | **`body { font-size: 18px }`** | Browser default (16px) is too small for comfortable long-form reading |

### Semantic HTML and Accessibility

| ID | Constraint |
|----|------------|
| S1 | **Skip link** — `<a href="#main-content">Skip to content</a>` on every page |
| S2 | **`aria-label` on every `<nav>`** |
| S3 | **`aria-current="page"` on the active nav link** |
| S4 | **Site title as `<p>`** on every page — reserves `<h1>` for page content. Optional: create `layouts/partials/logo.html` to render a custom logo (inline SVG recommended — no HTTP fetch) in place of the text title. |
| S5 | **`<time datetime="...">`** on blog post dates |
| S6 | **`<figure>` with `loading="lazy"`** for all images |
| S7 | **Breadcrumb navigation** — `<nav aria-label="Breadcrumb">` with `<ol>` on every docs page; section tab strip with `<nav aria-label="Docs sections">` on every docs page |

> **Docs hierarchy:** The docs templates assume a two-level structure:
> `/docs/<section>/<page>/`. Structures shallower or deeper than two levels
> will produce incomplete breadcrumb and section navigation. Hugo will emit a build warning
> if a docs page is detected more than two levels deep.

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
