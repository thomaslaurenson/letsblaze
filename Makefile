THEME     := letsblaze
SITE_DIR  := exampleSite
PUBLIC    := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)

.PHONY: build serve new_post new_doc test help

## build: build the exampleSite into public/
build:
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

## serve: start a local development server with live reload
serve:
	cd $(SITE_DIR) && hugo server $(HUGO_FLAGS)

## clean: remove the generated public/ directory
clean:
	rm -rf $(PUBLIC)

## new_post: create a new blog post  usage: make new_post NAME=my-post-title
new_post:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) blog/$(NAME).md

## new_doc: create a new doc page  usage: make new_doc NAME=section/my-page
new_doc:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) docs/$(NAME).md

## test: run the full constraint test suite
test:
	@bash scripts/test.sh

## help: list available targets
help:
	@grep -E '^## ' Makefile | sed 's/## //'
