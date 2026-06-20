SHELL      := /bin/bash

THEME      := letsblaze
SITE_DIR   := exampleSite
PUBLIC     := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the exampleSite into public/
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

.PHONY: serve
serve: ## Start a local development server with live reload
	cd $(SITE_DIR) && hugo server $(HUGO_FLAGS)

.PHONY: new_post
new_post: ## Create a new blog post (usage: make new_post NAME=my-post-title)
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) blog/$(NAME).md

.PHONY: new_doc
new_doc: ## Create a new doc page (usage: make new_doc NAME=section/my-page)
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) docs/$(NAME).md

.PHONY: test
test: ## Run the full constraint test suite
	@bash scripts/test.sh

.PHONY: clean
clean: ## Remove the generated public/ directory
	rm -rf $(PUBLIC)
