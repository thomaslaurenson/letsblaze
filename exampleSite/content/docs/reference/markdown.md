---
title: "Markdown Reference"
date: 2026-01-01
draft: false
description: "A complete reference for Markdown syntax supported by letsblaze, including headings, tables, code, lists, and blockquotes."
---

A reference for all Markdown elements supported by letsblaze. Use this page
to verify rendering before writing content.

## Headings

`<h1>` is reserved for the page title. Use `<h2>` to `<h6>` in content.

## H2
### H3
#### H4
##### H5
###### H6

## Paragraph

Standard paragraph text. Separate paragraphs with a blank line. Line breaks
within a paragraph are collapsed to a space unless you end a line with two
spaces or a backslash.

## Blockquotes

> Single-level blockquote.

> Nested blockquote.
>
> > Inner level.

With attribution:

> Do one thing and do it well.
>
> — <cite>Unix philosophy</cite>

## Lists

**Ordered:**

1. First
2. Second
3. Third

**Unordered:**

- Item
- Item
- Item

**Nested:**

- Fruit
  - Apple
  - Orange
- Dairy
  - Milk
  - Cheese

## Code

Inline: `const x = 42`

Fenced block:

```javascript
function add(a, b) {
  return a + b;
}
```

## Tables

| Column A | Column B | Column C |
| :------- | :------: | -------: |
| Left     | Centre   | Right    |
| aligned  | aligned  | aligned  |

## Horizontal rule

---

## Links

[Inline link](https://example.com)

[Link with title](https://example.com "Title text")

## Images

```markdown
![Alt text](image.jpg)
![Alt text with caption](image.jpg "Caption text")
```

## Footnotes

Text with a footnote.[^note]

[^note]: Footnote content renders at the bottom of the page.

## Inline formatting

| Style | Syntax | Output |
|-------|--------|--------|
| Bold | `**text**` | **text** |
| Italic | `_text_` | _text_ |
| Strikethrough | `~~text~~` | ~~text~~ |
| Inline code | `` `code` `` | `code` |
