THEME     := letsblaze
SITE_DIR  := exampleSite
PUBLIC    := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)

.PHONY: build clean rebuild check new-post new-doc

## build: build the exampleSite into public/
build:
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

## clean: remove the generated public/ directory
clean:
	rm -rf $(PUBLIC)

## rebuild: clean then build
rebuild: clean build

## check: rebuild and run all constraint + feature checks
check: rebuild
	@echo ""
	@echo "=== Constraint checks (all must be 0) ==="
	@echo "script tags:     $$(grep -rc '<script' $(PUBLIC) | grep -v ':0' | wc -l)"
	@echo "ext stylesheets: $$(grep -rc 'rel=\"stylesheet\"' $(PUBLIC) | grep -v ':0' | wc -l)"
	@echo "class attrs:     $$(grep -rc 'class=\"' $(PUBLIC) | grep -v ':0' | wc -l) files (Chroma code blocks expected)"
	@echo "cdn resources:   $$(grep -rc 'cdn\.' $(PUBLIC) | grep -v ':0' | wc -l)"
	@echo ""
	@echo "=== Feature checks ==="
	@echo "dark mode block: $$(grep -rc 'prefers-color-scheme' $(PUBLIC)/index.html)"
	@echo "skip link:       $$(grep -rc 'Skip to content' $(PUBLIC)/index.html)"
	@echo "overflow tables: $$(grep -rc 'overflow-x' $(PUBLIC)/docs/getting-started/installation/index.html)"
	@echo "blog prev/next:  $$(grep -rc 'prev —\|next —' $(PUBLIC)/blog/hello-world/index.html)"
	@echo "docs prev/next:  $$(grep -rc 'prev —\|next —' $(PUBLIC)/docs/getting-started/installation/index.html)"
	@echo ""
	@echo "=== Page inventory ==="
	@find $(PUBLIC) -name "*.html" | sort

## new-post: create a new blog post  usage: make new-post NAME=my-post-title
new-post:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) blog/$(NAME).md

## new-doc: create a new doc page  usage: make new-doc NAME=section/my-page
new-doc:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) docs/$(NAME).md

## help: list available targets
help:
	@grep -E '^## ' Makefile | sed 's/## //'
