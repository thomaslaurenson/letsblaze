---
title: "Welcome to letsblaze"
date: 2026-01-01
draft: false
tags: ["letsblaze", "performance", "html"]
description: "Why letsblaze exists — a Hugo theme built on the principle that the fastest resource is one that was never requested."
---

letsblaze is a Hugo theme built on one principle: the fastest resource is one that
was never requested.

No JavaScript. No external stylesheets. No web fonts. No CDN calls. Every page is
HTML with a small inline style block. Nothing else ships to the browser.

## Why no JavaScript

JavaScript is powerful and often necessary. It is also the single largest contributor
to slow page loads across the web. For a blog or documentation site, there is almost
nothing that JavaScript provides that semantic HTML cannot handle.

Collapsible navigation? `<details>` and `<summary>`. Skip links? Pure CSS.
Dark mode? `prefers-color-scheme` media query. Syntax highlighting? Chroma at
build time, baked into the HTML.

Every feature in letsblaze works without a single line of client-side script.

## Why inline CSS

External stylesheets require an additional HTTP request and block rendering until
they load. With inline CSS, the styles arrive with the HTML — no extra round trip,
no render blocking, no flash of unstyled content.

The letsblaze style block is small enough that the overhead is negligible, and the
simplicity benefit is real.

## Who this is for

letsblaze is for developers who want a site that scores well on Core Web Vitals
without any optimisation effort, readers who want a site that loads instantly on
any connection, and authors who want to write in Markdown without thinking about
the theme at all.

If you want animation, infinite scroll, or a JavaScript-powered search modal,
letsblaze is probably not your theme.

If you want fast, readable, and durable — it might be exactly right.
