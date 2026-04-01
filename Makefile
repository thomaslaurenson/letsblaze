THEME     := letsblaze
SITE_DIR  := exampleSite
PUBLIC    := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)

.PHONY: build serve clean rebuild check new-post new-doc

## build: build the exampleSite into public/
build:
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

# serve: start a local development server with live reload
serve:
	cd $(SITE_DIR) && hugo server $(HUGO_FLAGS)

## clean: remove the generated public/ directory
clean:
	rm -rf $(PUBLIC)

## rebuild: clean then build
rebuild: clean build

## check: run the full test suite (build + constraint + feature checks)
check:
	@bash test.sh
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
