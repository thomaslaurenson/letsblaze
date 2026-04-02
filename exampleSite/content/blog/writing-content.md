---
title: "Writing Content"
date: 2026-01-15
draft: false
tags: ["markdown", "content", "writing"]
description: "A guide to writing content with letsblaze — headings, lists, blockquotes, footnotes, and inline elements."
---

letsblaze renders standard Markdown with a few additions. This post covers
everything available when writing content.

## Headings

`<h1>` is reserved for the page title, rendered automatically by the theme.
Use `<h2>` through `<h6>` for section headings within content.

## H2
### H3
#### H4
##### H5
###### H6

## Lists

Ordered and unordered lists render with clean browser defaults.

1. First item
2. Second item
3. Third item

- Unordered item
- Another item
- And another

## Blockquotes

> The web is for everyone. Build accordingly.

Attribution with a cite element:

> Fast sites are kind sites.
>
> — <cite>Someone who cares about UX</cite>

## Footnotes

Standard Markdown footnotes work out of the box.[^1]

[^1]: Footnotes render at the bottom of the page with back-links.

## Inline elements

Standard Markdown inline elements:

- **Bold** — `**text**`
- _Italic_ — `_text_`
- `Code` — `` `code` ``
- ~~Strikethrough~~ — `~~text~~`

letsblaze also ships shortcodes for elements with no Markdown equivalent:

- Subscript: H{{< sub >}}2{{< /sub >}}O
- Superscript: E = mc{{< sup >}}2{{< /sup >}}
- Highlight: {{< mark >}}marked text{{< /mark >}}
- Abbreviation: {{< abbr title="HyperText Markup Language" >}}HTML{{< /abbr >}}

## Emoji

With `enableEmoji = true` in `hugo.toml`, use shorthand codes: :rocket: :tada: :fire:

Unicode decimal and hexadecimal codes also work everywhere without configuration:
&#128516; &#x1F525;
