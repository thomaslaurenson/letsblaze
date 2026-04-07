---
title: "Code and Syntax Highlighting"
date: 2026-02-01
draft: false
tags: ["code", "syntax", "markdown"]
description: "How letsblaze handles code blocks and syntax highlighting using Chroma with inline styles and no external CSS."
---

letsblaze uses Hugo's built-in Chroma syntax highlighter, configured to emit
inline styles rather than CSS classes. This means syntax highlighting works
with no external stylesheet — consistent with the theme's no-external-resources
philosophy.

## Inline code

Wrap short code references in backticks: `const x = 42`.

## Fenced code blocks

Use triple backticks with a language identifier:

```python
def greet(name: str) -> str:
    return f"Hello, {name}"

print(greet("world"))
```

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Example</title>
  </head>
  <body>
    <p>Hello, world.</p>
  </body>
</html>
```

```bash
hugo new blog/my-post.md
hugo server --buildDrafts
hugo --minify
```

## Syntax style

letsblaze is opinionated: the default Chroma style is `monochrome`. This works
in both light and dark mode without maintaining two colour palettes.

To use a different style, change `style` in `hugo.toml`:

```toml
[markup.highlight]
  noClasses = true
  style = "github"  # see https://xyproto.github.io/splash/docs/
```

Note that non-monochrome styles may not work well in dark mode without additional
CSS overrides.
