# letsblaze

Blazingly fast, highly opinionated flyweight Hugo theme

## Philosophy

letsblaze is built around one principle: **the fastest resource is one that was never requested.**

- :no_entry: No JavaScript
- :link: No CSS
- :pencil2: No web fonts
- :cloud: No CDN calls
- :rocket: Plain HTML with a single inline `<style>`

### The hard rule

The constraint that never bends is about the **network**: no JavaScript, no external requests, fast. Every page is self-contained HTML with one inline `<style>` block. Nothing else ships to the browser. The R-series constraints below enforce this and are non-negotiable.

### Where the CSS line is drawn

"Minimal CSS" is *not* the rule. It was once used as a proxy for the hard rule above, and that proxy is misleading. Because the CSS is already inline, one more selector costs a few dozen bytes inside an already-loaded document. It triggers no request and no render-blocking. So the amount of CSS is the wrong thing to police.

The right question for any rule is: **does it earn its bytes by serving reading or navigation?** A CSS rule is **allowed** if it does one of three things:

1. **Prevents a usability failure**: unreadable line length, invisible focus state, or content that can't be navigated to

1. **Communicates structure**: show "where am I" from "where can I go," or separating navigation from content

1. **Respects user or OS intent**: dark mode, reduced motion, system fonts

A CSS rule is **rejected** if it only decorates: gradients, drop shadows, brand accent colours, rounded corners, hover animations, or anything whose only loss, if removed, is that the page looks less styled.

## Features

- **No JavaScript**: no `<script>` tags of any kind; `<details>` and CSS do the interactive work
- **No external requests**: no linked stylesheets, web fonts, or CDN calls, just one inline `<style>` per page
- **Dark mode**: follows the OS `prefers-color-scheme` setting, with no toggle, cookie, or flash
- **Blog and docs**: a paginated blog with tags and per-tag feeds, plus a nested docs section with breadcrumbs
- **Math**: LaTeX renders to native MathML at build time, so no KaTeX or MathJax ships to the reader
- **Syntax highlighting**: Chroma highlights code at build time with inline styles, in a monochrome palette
- **Images**: `embed`, `link-same-tab`, and `link-new-tab` modes, with `<figure>` captions and LCP-aware loading
- **Accessible**: skip link, labelled landmarks, `aria-current`, and semantic HTML throughout
- **SEO**: canonical URLs, Open Graph tags, Schema.org microdata, RSS autodiscovery, and a sitemap
- **Shortcodes**: `sub`, `sup`, `mark`, and `abbr`

See the theme running at **[letsblaze.thomaslaurenson.com](https://letsblaze.thomaslaurenson.com)**, which doubles as the documentation: [Installation](https://letsblaze.thomaslaurenson.com/docs/getting-started/installation/), [Configuration](https://letsblaze.thomaslaurenson.com/docs/getting-started/configuration/), [Features](https://letsblaze.thomaslaurenson.com/docs/reference/features/), and [Markdown](https://letsblaze.thomaslaurenson.com/docs/reference/markdown/).

## Installation

### Requirements

* Hugo **0.146.0 or later**

### Option 1: Git submodule (recommended)

Add letsblaze as a git submodule:

```bash
git submodule add https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

Set the theme in your `hugo.toml`:

```toml
theme = "letsblaze"
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

Set the theme in your `hugo.toml`:

```toml
theme = "letsblaze"
```

To update, delete the folder and clone again, or `git pull` inside it.

### Option 3: Hugo Modules

Requires Go to be installed. Your site must be a Hugo module:

```bash
hugo mod init github.com/<you>/<your-site>
```

Set the theme in your `hugo.toml`, using the full module path:

```toml
theme = "github.com/thomaslaurenson/letsblaze"
```

Hugo downloads it on the next build. To update later:

```bash
hugo mod get -u github.com/thomaslaurenson/letsblaze
```

## Constraints

Every design decision is governed by a numbered constraint. These identifiers are used in `scripts/test.sh` so test failures trace directly to this document.

Constraints are grouped by category with a category prefix:

- **R**: Resources & CSS authoring
- **C**: CSS integrity
- **S**: Semantic HTML
- **M**: SEO & metadata

### Resources & CSS authoring

| ID | Constraint |
|---|---|
| R1 | **No JavaScript**: no `<script>` tags of any kind |
| R2 | **No external CSS**: no `rel="stylesheet"` links |
| R3 | **No CDN resources**: no cdn., fonts.googleapis, or fonts.gstatic URLs |
| R4 | **No inline `style=`**: no `style=` attributes on HTML elements (Chroma `<span>` and `<pre>` are exempt). Code fence line numbers are ignored because Chroma renders them as a `<table>` with inline styles; `hl_lines` is honoured. Hugo's default table output aligns cells with `style="text-align"`, so the theme's table render hook writes `data-align` attributes instead (see C17). |
| R5 | **No CSS frameworks or utility classes**: no Tailwind/Bootstrap/etc., no atomic or utility classes (e.g. `mt-4`, `flex`), and no class used purely for decoration. Semantic classes that *name a structural region* (e.g. `docs-sidebar`, `breadcrumb`) are permitted, because they enable structure-communicating CSS that is already inline and costs no request. Chroma and Goldmark footnote classes remain exempt. |

### CSS integrity

All CSS is inline inside a `<style>` block in `<head>`, in `layouts/_partials/head-styles.html`. Every rule has an explicit justification.

New rules must pass the gate in [Philosophy](#where-the-css-line-is-drawn): they prevent a usability failure, communicate structure, or respect user/OS intent. Decorative rules are rejected. When adding a constraint here, give it the next `C` number and a one-line justification, then add a matching check in `scripts/test.sh`.

| ID | Constraint | Justification |
|---|---|---|
| C1  | **CSS inline in `<head>`** | No linked file = no extra HTTP request, no render blocking, no FOUC |
| C2  | **Skip link hidden off-screen** | `position: absolute; left: -9999px`, revealed on `:focus` with `z-index: 1`, `background`, and `padding` to ensure visibility |
| C3  | **`body { max-width: 100ch; margin: 0 auto; padding: 1rem }`** | Prevents unreadable line lengths on wide viewports; the auto margin centres the column and the padding keeps text off the viewport edge on narrow screens |
| C4  | **`body { line-height: 1.6 }`** | Browser default is too tight for comfortable reading |
| C5  | **`img { max-width: 100%; height: auto }`** | Responsive images; `height: auto` prevents CLS alongside explicit `width`/`height` attributes |
| C6  | **`table { border-collapse: collapse }`** | `.table-wrap { overflow-x: auto }` on the wrapper emitted by the table render hook confines horizontal scroll to the table itself, so the page never scrolls sideways. A wrapper is used rather than `display: block` on the table because changing a table's display strips its semantics in some browsers, notably Safari |
| C7  | **`nav ul { list-style: none; margin: 0; padding: 0 }`** | Removes browser bullet and indent defaults from all nav lists; the breadcrumb `<ol>` gets the same reset |
| C8  | **`[aria-current="page"] { font-weight: bold }`** | Active-link indicator without a class |
| C9  | **Dark mode via `prefers-color-scheme: dark`** | Follows OS preference (no JavaScript, no toggle, no cookie). The block restyles the body, links, inline code, `<mark>`, table borders and the skip link so each keeps readable contrast on the dark background; fenced code keeps Chroma's own inline colours |
| C10 | **`pre { overflow-x: auto }`** | Wide code blocks scroll horizontally instead of being clipped |
| C11 | **`body { font-size: 18px }`** | Browser default (16px) is too small for comfortable long-form reading |
| C12 | *Retired* | Post lists are `<ul>` elements, so the former `article + article` spacing rule matched nothing and was removed. The number is kept so older references still resolve |
| C13 | **`math[display="block"] { overflow-x: auto }`** | Wide display equations scroll horizontally within their own box instead of overflowing the page, mirroring C6 (tables) and C10 (code) |
| C14 | **`li { display: inline }` in the header, breadcrumb and tag navs** | Lays navigation out on one line so it reads as a strip separate from the content, instead of a vertical list that pushes the page down; the list markup stays so assistive technology still announces item counts |
| C15 | **`:root { color-scheme: light dark }`** | Tells the browser both schemes are supported, so scrollbars, form controls and the `<details>` marker follow the OS preference instead of staying light; C9 only restyles the theme's own elements |
| C16 | **`th, td { border: 1px solid; padding: 0.4rem 0.8rem }`** | Cell borders and padding keep tabular data readable; without them columns run together and rows cannot be followed across |
| C17 | **`[data-align] { text-align }`** | Honours the column alignment the author wrote in Markdown. Hugo's default table output does this with `style="text-align"`, which R4 forbids, so `layouts/_markup/render-table.html` emits `data-align` attributes instead |
| C18 | **`li + li::before { content: " / " / "" }`** in the header and breadcrumb navs | Separates inline nav items so they do not run together. The alternative-text form hides the glyph from screen readers, which would otherwise announce it |
| C19 | **`.post-meta { display: grid }`** | Lays the blog post date, tags and author out as label and value columns, so the block reads as metadata rather than as body text and stays compact; `.post-meta dt` is bold to mark the labels |

### Semantic HTML and accessibility

| ID | Constraint |
|---|---|
| S1 | **Skip link**: `<a href="#main-content">Skip to content</a>` on every page |
| S2 | **`aria-label` on every `<nav>`** |
| S3 | **`aria-current="page"` on the active nav link** |
| S4 | **Site title as bare `<a>`** on every page, reserves `<h1>` for page content. Optionally replaced by a custom logo partial (see [Logo](https://letsblaze.thomaslaurenson.com/docs/getting-started/configuration/#logo-optional)). |
| S5 | **`<time datetime="...">`** on blog post dates |
| S6 | **Image rendering controlled by `imageMode` param**: three modes: `embed` (default): wraps a standalone image in `<figure>` (see [Images](https://letsblaze.thomaslaurenson.com/docs/reference/features/#images)) and renders any other image as a bare `<img>`, first image on page uses `loading="eager" fetchpriority="high"`, subsequent images use `loading="lazy"`; `link-same-tab`: renders a bare `<a>` link using alt text; `link-new-tab`: same with `target="_blank" rel="noopener noreferrer"`. Overridable per-page in front matter. |
| S7 | **Breadcrumb navigation**: `<nav aria-label="Breadcrumb">` with `<ol>` on every blog post page and every docs page below the docs root, which has no ancestors to show; breadcrumb walks `.Ancestors` so arbitrary nesting depth is supported. |

### SEO and metadata

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
