---
title: "Tags and Taxonomy"
date: 2026-03-01
draft: false
tags: ["tags", "taxonomy", "organisation"]
description: "How letsblaze handles tags and taxonomy pages — automatic tag indexes, post counts, and RSS feeds per tag."
---

letsblaze supports Hugo's built-in taxonomy system. Tags are the primary taxonomy.

## Adding tags to a post

In front matter:

```yaml
---
title: "My Post"
tags: ["hugo", "web", "html"]
---
```

## Tag pages

Every tag automatically gets a listing page at `/tags/TAG-NAME/` showing all posts with that tag, with pagination. The tags index at `/tags/` lists all tags ordered by post count.

## RSS per tag

Hugo generates an RSS feed for each tag automatically:

```
/tags/hugo/index.xml
```

This lets readers subscribe to specific topics rather than the full blog feed.

## Naming conventions

Tag names are lowercased and slugified automatically. `Hugo Theme` becomes `hugo-theme` in the URL. Use consistent, lowercase tag names in front matter to avoid duplicate taxonomy terms.
