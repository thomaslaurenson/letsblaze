---
title: "Features"
date: 2026-01-01
draft: false
description: "A complete reference for all letsblaze theme features — shortcodes, dark mode, RSS, accessibility, and SEO."
---

## No JavaScript

letsblaze ships zero client-side JavaScript. All interactive behaviour uses
native HTML elements (`<details>`, `<summary>`) or CSS (`prefers-color-scheme`,
`aria-current`).

## No external resources

No external stylesheets, no web fonts, no CDN calls. All styles are inline.
Every page is self-contained.

## Dark mode

Dark mode is automatic — it follows the system `prefers-color-scheme` preference.
No toggle, no JavaScript, no cookie. It just works.

## Syntax highlighting

Code blocks are highlighted at build time using Hugo's Chroma highlighter with
inline styles. The default style is `monochrome`. See Configuration for how to
change it.

## RSS

Hugo generates RSS feeds automatically:

- `/index.xml` — full site feed
- `/blog/index.xml` — blog feed
- `/tags/TAG/index.xml` — per-tag feed

The feed link is autodiscoverable in `<head>` and linked in the footer.

## Sitemap

A sitemap is generated automatically at `/sitemap.xml`. With `enableGitInfo = true`,
`lastmod` is populated from git commit dates.

## Accessibility

- Skip link for keyboard navigation
- `aria-label` on all `<nav>` elements
- `aria-current="page"` on active navigation links
- Semantic HTML throughout — `<article>`, `<aside>`, `<time>`, `<figure>`, `<nav>`
- `<details>`/`<summary>` for collapsible docs navigation

## SEO

- `<meta name="description">` — falls back through page description → summary → site description
- Canonical URL on every page
- Open Graph tags (`og:title`, `og:description`, `og:type`, `og:url`, `og:site_name`)
- `article:published_time` and `article:modified_time` on blog posts
- JSON-LD Article schema on blog posts
- `noindex` on 404

## Shortcodes

| Shortcode | Output | Example |
|-----------|--------|---------|
| `{{</* sub */>}}text{{</* /sub */>}}` | Subscript | H{{< sub >}}2{{< /sub >}}O |
| `{{</* sup */>}}text{{</* /sup */>}}` | Superscript | x{{< sup >}}2{{< /sup >}} |
| `{{</* mark */>}}text{{</* /mark */>}}` | Highlighted text | {{< mark >}}important{{< /mark >}} |
| `{{</* abbr title="..." */>}}text{{</* /abbr */>}}` | Abbreviation | {{< abbr title="HyperText Markup Language" >}}HTML{{< /abbr >}} |
