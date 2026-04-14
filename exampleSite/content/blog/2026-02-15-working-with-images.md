---
title: "Working with Images"
date: 2026-02-15
draft: false
tags: ["images", "markdown", "page-bundles"]
description: "How to use images in letsblaze — imageMode param, page bundles, captions, and automatic dimension detection for CLS-free layouts."
---

letsblaze handles images with a custom render hook that supports three rendering
modes controlled by the `imageMode` param, plus automatic dimension detection
for page-bundle images.

## Image mode

The `imageMode` param controls how Markdown images are rendered. Set it
site-wide in `hugo.toml` or override it per page in front matter.

| Value | Output |
|-------|--------|
| `embed` (default) | Wraps the image in a `<figure>` element |
| `link-same-tab` | Renders a bare `<a>` link using the alt text as link text |
| `link-new-tab` | Same as `link-same-tab` but opens in a new tab with `rel="noopener noreferrer"` |

Site-wide in `hugo.toml`:

```toml
[params]
  imageMode = "embed"
```

Per-page in front matter:

```yaml
---
imageMode: link-same-tab
---
```

## Eager and lazy loading

In `embed` mode, the first image on a page (`Ordinal 0`) is treated as a
likely above-the-fold image. It is rendered with `loading="eager"` and
`fetchpriority="high"` to improve Largest Contentful Paint (LCP). All
subsequent images use `loading="lazy"`.

This is automatic — no configuration required.

## Page bundles

The recommended way to use images is as page bundles — store the image alongside
the content file:

```
content/
  blog/
    working-with-images/
      index.md        ← this file
      hero.jpg        ← image in the same directory
```

This is a leaf bundle. Hugo can read the image dimensions at build time and emit
`width` and `height` attributes automatically, preventing layout shift (CLS).

## Basic image

Standard Markdown syntax:

```markdown
![A descriptive alt text](hero.jpg)
```

## Image with caption

Add a title in quotes after the path to render a `<figcaption>`:

```markdown
![Alt text](hero.jpg "This becomes the visible caption")
```

## External images

External URLs work but Hugo cannot read their dimensions. The image renders
without `width`/`height` attributes. This is correct behaviour — no dimensions
are better than wrong dimensions.

```markdown
![Alt text](https://example.com/image.jpg)
```

## Alt text

Always write descriptive alt text. It is read by screen readers and displayed
when the image fails to load. An empty `alt=""` is correct for purely decorative
images — it tells screen readers to skip the element.
