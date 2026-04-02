---
title: "Configuration"
date: 2026-01-01
draft: false
description: "All configuration options for the letsblaze Hugo theme."
---

All letsblaze configuration lives in `hugo.toml`. Below is a complete reference
for every supported parameter.

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

## Markup

```toml
[markup.goldmark.renderer]
  unsafe = true  # required for shortcodes like <kbd>, <del>, <mark>

[markup.highlight]
  noClasses = true   # required — letsblaze has no external CSS
  style = "monochrome"
```

## Theme params

```toml
[params]
  author = "Your Name"
  copyright = "Your Name"          # falls back to site title if not set
  description = "Site description" # used in meta tags and homepage
  dateFormat = "2006-01-02"        # Go reference time format
  homepagePostCount = 5            # recent posts shown on homepage
  showThemeCredit = true           # set false to hide "Theme: letsblaze" in footer
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

Add as many items as needed. `weight` controls order — lower numbers appear first.
