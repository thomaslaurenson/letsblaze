---
title: "Configuration"
date: 2026-01-01
draft: false
weight: 2
description: "All configuration options for the letsblaze Hugo theme."
---

All letsblaze configuration lives in `hugo.toml`. Below is a complete reference for every supported parameter.

## Top-level settings

| Key | Recommended value | Notes |
|-----|------------------|-------|
| `languageCode` | `en-US` | Use BCP 47 format with uppercase region subtag |
| `enableEmoji` | `true` | Enables `:shortcode:` emoji syntax in content |
| `enableGitInfo` | `true` | Sets `lastmod` in sitemap from git commit dates |
| `disableHugoGeneratorInject` | `false` | letsblaze keeps the Hugo generator tag intentionally |

## Pagination

```toml
[pagination]
  pagerSize = 10
```

## Taxonomies

```toml
[taxonomies]
  tag = "tags"
```

letsblaze ships layouts for tags only. Listing just `tags` stops Hugo generating the default `categories` pages and feed that nothing links to.

## Front matter

```toml
[frontmatter]
  date = [":filename", ":default"]
```

A blog post named `YYYY-MM-DD-my-post.md` takes its date from the filename and its slug from the rest, so `make new_post NAME=2026-09-17-my-post` publishes at `/blog/my-post/` with a clean title. A file without the prefix falls back to the `date` in its front matter.

## Markup

```toml
[markup.goldmark.parser]
  wrapStandAloneImageWithinParagraph = false  # lets a standalone image render as a <figure>

[markup.goldmark.renderer]
  unsafe = true  # required for shortcodes like <kbd>, <del>, <mark>

[markup.highlight]
  noClasses = true   # required, letsblaze has no external CSS
  style = "monochrome"
```

### Images (optional)

In the default `embed` mode a standalone image renders as a `<figure>`, with its title as the `<figcaption>`. Goldmark wraps a standalone image in a paragraph unless told otherwise, and a `<figure>` inside a `<p>` is invalid HTML, so the render hook only emits one when your site sets `wrapStandAloneImageWithinParagraph = false` above. Hugo does not merge a theme's `markup` configuration, so this has to live in your own `hugo.toml`. Without it every image renders as a bare `<img>` inside its paragraph and the title becomes a `title` attribute. See the [Images](../../reference/features/#images) reference for the three `imageMode` values.

### Math (optional)

To render LaTeX math, enable Goldmark's passthrough extension so the theme's render hook can turn it into MathML at build time. This is opt-in because Hugo does not merge a theme's `markup` configuration, so it must live in your site's `hugo.toml`:

```toml
[markup.goldmark.extensions.passthrough]
  enable = true
  [markup.goldmark.extensions.passthrough.delimiters]
    block  = [['$$', '$$'], ['\[', '\]']]
    inline = [['\(', '\)']]
```

With this in place, `$$...$$` and `\[...\]` render as display math and `\(...\)` as inline math. No JavaScript or external stylesheet is added: the browser renders the MathML natively. See the [Math](../../reference/markdown/#math) reference for examples. Single `$` is intentionally left out of the delimiters so prices and shell variables in prose are never misparsed.

## Theme params

```toml
[params]
  author = "Your Name"
  copyright = "Your Name"          # falls back to site title if not set
  description = "Site description" # used in meta tags and homepage
  dateFormat = "2006-01-02"        # Go reference time format
  homepagePostCount = 5            # recent posts shown on homepage
  showThemeCredit = true           # set false to hide "Theme: letsblaze" in footer
  imageMode = "embed"              # embed | link-same-tab | link-new-tab
  # ogImage = "/og-image.png"      # path to default OG image in static/
```

## Menus

Navigation items are defined in `hugo.toml`:

```toml
[[menus.main]]
  name = "Blog"
  url = "/blog/"
  weight = 1
```

Add as many items as needed. `weight` controls order, with lower numbers appearing first.

## Logo (optional)

To use a custom logo instead of the plaintext site title, create `layouts/partials/logo.html` in your site (not in the theme). Inline SVG is recommended, as it requires no extra HTTP request and stays consistent with the theme's no-external-resources philosophy.

Example `layouts/partials/logo.html`:

```html
<a href="{{ .Site.Home.RelPermalink }}">
  <svg xmlns="http://www.w3.org/2000/svg" width="120" height="32" aria-label="{{ .Site.Title }}">
    <!-- your SVG content here -->
  </svg>
</a>
```
