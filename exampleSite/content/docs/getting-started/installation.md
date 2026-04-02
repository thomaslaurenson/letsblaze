---
title: "Installation"
date: 2026-01-01
draft: false
description: "How to install the letsblaze Hugo theme as a git submodule, Hugo module, or manual download."
---

letsblaze requires Hugo **0.134.0 or later**. Run `hugo version` to check.

## Option 1 — Git submodule (recommended)

```bash
cd your-hugo-site
git submodule add https://github.com/thomaslaurenson/letsblaze themes/letsblaze
```

In `hugo.toml`:

```toml
theme = "letsblaze"
```

To update the theme later:

```bash
git submodule update --remote --merge
```

## Option 2 — Hugo module

Initialise your site as a Hugo module if you haven't already:

```bash
hugo mod init github.com/YOUR-USERNAME/YOUR-SITE
```

In `hugo.toml`:

```toml
[module]
  [[module.imports]]
    path = "github.com/thomaslaurenson/letsblaze"
```

Pull the module:

```bash
hugo mod get
```

## Option 3 — Manual download

Download the repository as a zip from GitHub and extract it into `themes/letsblaze/`.
Set `theme = "letsblaze"` in `hugo.toml`.

This method requires manual updates.

## Verify

Run the development server:

```bash
hugo server
```

Open `http://localhost:1313` in a browser. If the page renders, installation is complete.
