# letsblaze

Blazingly fast, highly opinionated flyweight Hugo theme

## Philosophy

letsblaze is built around one principle: **the fastest resource is one that was never requested.**

- :no_entry: No JavaScript
- :link: No external stylesheets
- :pencil2: No web fonts
- :cloud: No CDN calls
- :rocket: Plain HTML with a single inline `<style>`

### The hard rule

The constraint that never bends is about the **network**: no JavaScript, no external requests, fast. Every page is self-contained HTML with one inline `<style>` block. Nothing else ships to the browser. The R-series constraints below enforce this and are non-negotiable.

### Where the CSS line is drawn

"Minimal CSS" is *not* the rule. It was once used as a proxy for the hard rule above, and that proxy is misleading. Because the CSS is already inline, one more selector costs a few dozen bytes inside an already-loaded document. It triggers no request and no render-blocking. So the amount of CSS is the wrong thing to police.

The right question for any rule is: **does it earn its bytes by serving reading or navigation?**

A CSS rule is **allowed** if it does one of three things:

1. **Prevents a usability failure**: unreadable line length, an invisible focus state, layout shift, or content that can't be navigated to.

1. **Communicates structure**: distinguishing "where am I" from "where can I go," or separating navigation from content.

1. **Respects user or OS intent**: dark mode, reduced motion, system fonts.

A CSS rule is **rejected** if it only decorates: gradients, drop shadows, brand accent colours, rounded corners, hover animations, or anything whose only loss, if removed, is that the page looks less styled.

The test to hold in your head while editing: *if I removed this rule, would a reader get lost, strain to read, or see the page jump?* If yes, keep it. If the only loss is decoration, cut it. Every constraint in the CSS Integrity table passes this gate.

## Installation

letsblaze requires Hugo **0.134.0 or later**.

### Option 1: Git submodule (recommended)

Add letsblaze as a git submodule:

```bash
git submodule add https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

To update the theme later:

```bash
git submodule update --remote themes/letsblaze
```

### Option 2: Manual clone

This method is beginner-friendly and has no Git dependency management.

```bash
git clone https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

To update, delete the folder and clone again, or `git pull` inside it.

### Option 3: Hugo Modules

Requires Go to be installed. Add the theme with `hugo mod`:

```bash
hugo mod get github.com/thomaslaurenson/letsblaze
```

### Set the theme

For options 1 and 2, set the theme in your `hugo.toml`:

```toml
theme = "letsblaze"
```

For option 3 (Hugo Modules), import it instead:

```toml
[module]
  [[module.imports]]
    path = "github.com/thomaslaurenson/letsblaze"
```

### Logo (optional)

To use a custom logo instead of the plain text site title, create `layouts/partials/logo.html` in your site (not in the theme). Inline SVG is recommended, as it requires no extra HTTP request and stays consistent with the theme's no-external-resources philosophy.

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

- **R**: Resources & CSS authoring
- **C**: CSS Integrity
- **S**: Semantic HTML
- **M**: SEO & Metadata

### Resources & CSS authoring

| ID | Constraint |
|---|---|
| R1 | **No JavaScript**: no `<script>` tags of any kind |
| R2 | **No external CSS**: no `rel="stylesheet"` links |
| R3 | **No CDN resources**: no cdn., fonts.googleapis, or fonts.gstatic URLs |
| R4 | **No inline `style=`**: no `style=` attributes on HTML elements (Chroma `<span>` and `<pre>` are exempt) |
| R5 | **No CSS frameworks or utility classes**: no Tailwind/Bootstrap/etc., no atomic or utility classes (e.g. `mt-4`, `flex`), and no class used purely for decoration. Semantic classes that *name a structural region* (e.g. `docs-sidebar`, `breadcrumb`) are permitted, because they enable structure-communicating CSS that is already inline and costs no request. Chroma and Goldmark footnote classes remain exempt. |

### CSS Integrity

All CSS is inline inside a `<style>` block in `<head>`, in `layouts/_partials/head-styles.html`. Every rule has an explicit justification.

New rules must pass the gate in [Philosophy](#where-the-css-line-is-drawn): they prevent a usability failure, communicate structure, or respect user/OS intent. Decorative rules are rejected. When adding a constraint here, give it the next `C` number and a one-line justification, then add a matching check in `scripts/test.sh`.

| ID | Constraint | Justification |
|---|---|---|
| C1  | **CSS inline in `<head>`** | No linked file = no extra HTTP request, no render blocking, no FOUC |
| C2  | **Skip link hidden off-screen** | `position: absolute; left: -9999px`, revealed on `:focus` with `z-index: 1`, `background`, and `padding` to ensure visibility |
| C3  | **`body { max-width: 100ch }`** | Prevents unreadable line lengths on wide viewports |
| C4  | **`body { line-height: 1.6 }`** | Browser default is too tight for comfortable reading |
| C5  | **`img { max-width: 100%; height: auto }`** | Responsive images; `height: auto` prevents CLS alongside explicit `width`/`height` attributes |
| C6  | **`table { border-collapse: collapse }`** | `display: block; overflow-x: auto` confines horizontal scroll to the table itself. Page never scrolls sideways; `display: block` is required to make `overflow-x` take effect on table elements |
| C7  | **`nav ul { list-style: none }`** | Removes browser bullet and indent defaults from all nav lists |
| C8  | **`[aria-current="page"] { font-weight: bold }`** | Active-link indicator without a class |
| C9  | **Dark mode via `prefers-color-scheme: dark`** | Follows OS preference (no JavaScript, no toggle, no cookie) |
| C10 | **`pre { overflow-x: auto }`** | Wide code blocks scroll horizontally instead of being clipped |
| C11 | **`body { font-size: 18px }`** | Browser default (16px) is too small for comfortable long-form reading |
| C12 | **`article + article { margin-top: 2rem }`** | Separates post list entries with whitespace instead of `<hr>` for a cleaner visual rhythm |

### Semantic HTML and Accessibility

| ID | Constraint |
|---|---|
| S1 | **Skip link**: `<a href="#main-content">Skip to content</a>` on every page |
| S2 | **`aria-label` on every `<nav>`** |
| S3 | **`aria-current="page"` on the active nav link** |
| S4 | **Site title as bare `<a>`** on every page, reserves `<h1>` for page content. Optionally replaced by a custom logo partial (see [Logo](#logo-optional)). |
| S5 | **`<time datetime="...">`** on blog post dates |
| S6 | **Image rendering controlled by `imageMode` param**: three modes: `embed` (default): wraps image in `<figure>`, first image on page uses `loading="eager" fetchpriority="high"`, subsequent images use `loading="lazy"`; `link-same-tab`: renders a bare `<a>` link using alt text; `link-new-tab`: same with `target="_blank" rel="noopener noreferrer"`. Overridable per-page in front matter. |
| S7 | **Breadcrumb navigation**: `<nav aria-label="Breadcrumb">` with `<ol>` on every docs page and every blog post page; breadcrumb walks `.Ancestors` so arbitrary nesting depth is supported. |

### SEO and Metadata

| ID | Constraint |
|---|---|
| M1  | **`<meta charset>` and viewport** on every page |
| M2  | **Canonical URL**: `<link rel="canonical">` on every page |
| M3  | **Meta description**: falls back through page description, summary, then site description |
| M4  | **Open Graph tags**: `og:title`, `og:description`, `og:type`, `og:url` on every page |
| M5  | **`og:site_name`** on every page |
| M6  | **Schema.org microdata**: blog posts carry `itemscope itemtype="...BlogPosting"` (no `<script>` required) |
| M7  | **`article:published_time` and `article:modified_time`** on blog posts |
| M8  | **RSS autodiscovery**: `<link rel="alternate" type="application/rss+xml">` in `<head>` on pages with feeds |
| M9  | **`noindex` in `<head>`** on the 404 page |
| M10 | **`<meta name="author">`** on every page |
