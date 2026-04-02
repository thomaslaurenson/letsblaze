THEME     := letsblaze
SITE_DIR  := exampleSite
PUBLIC    := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)

.PHONY: build serve new-post new-doc

## build: build the exampleSite into public/
build:
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

# serve: start a local development server with live reload
serve:
	cd $(SITE_DIR) && hugo server $(HUGO_FLAGS)

## clean: remove the generated public/ directory
clean:
	rm -rf $(PUBLIC)

## new-post: create a new blog post  usage: make new-post NAME=my-post-title
new-post:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) blog/$(NAME).md

## new-doc: create a new doc page  usage: make new-doc NAME=section/my-page
new-doc:
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) docs/$(NAME).md

## help: list available targets
help:
	@grep -E '^## ' Makefile | sed 's/## //'
