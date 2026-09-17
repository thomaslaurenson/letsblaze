---
title: "{{ .File.ContentBaseName | replaceRE "^\\d{4}-\\d{2}-\\d{2}-" "" | replace "-" " " | title }}"
date: {{ .Date }}
draft: true
tags: []
# description: used in meta tags and post summaries, always set this
description: ""
---
