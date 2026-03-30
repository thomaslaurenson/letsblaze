---
title: "Letsblaze Features"
date: 2024-01-01
summary: "A tour of features and content shortcodes in the letsblaze theme."
draft: false
---

A quick tour of letsblaze content features.

## Emoji

Add `enableEmoji = true` to `hugo.toml` and use shorthand codes like `:rocket:` :rocket: or `:tada:` :tada:. Raw Unicode decimal (e.g. `&#128516;` → &#128516;) and hexadecimal (e.g. `&#x1F604;`) codes work everywhere without any configuration.

## Code

Use fenced code blocks with a language identifier for syntax highlighting:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Example</title>
  </head>
  <body>
    <p>Hello, world.</p>
  </body>
</html>
```

Inline code is wrapped in backticks: `x = 42`.

## Inline Semantic Elements

Letsblaze ships shortcodes for elements that have no Markdown equivalent.

Subscript: H{{< sub >}}2{{< /sub >}}O

Superscript: E = mc{{< sup >}}2{{< /sup >}}

Highlight: Most {{< mark >}}salamanders{{< /mark >}} are nocturnal.
