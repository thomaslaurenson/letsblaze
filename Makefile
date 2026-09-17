SHELL := /bin/bash

THEME      := letsblaze
SITE_DIR   := exampleSite
PUBLIC     := $(SITE_DIR)/public
HUGO_FLAGS := --themesDir ../.. --theme $(THEME)
SCRIPTS    := scripts/test.sh

##@ BUILD

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^##@ / {printf "\n%s\n", substr($$0, 5)} \
		/^[a-zA-Z_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the exampleSite into public/
	cd $(SITE_DIR) && hugo $(HUGO_FLAGS)

.PHONY: serve
serve: ## Start a local development server with live reload
	cd $(SITE_DIR) && hugo server $(HUGO_FLAGS)

##@ TEST

.PHONY: test
test: ## Run the full constraint test suite
	@bash scripts/test.sh

##@ LINT

.PHONY: check_syntax
check_syntax: ## Fail if any script does not parse
	@for f in $(SCRIPTS); do bash -n "$$f" || exit 1; done

.PHONY: check_lint
check_lint: ## Run shellcheck over every script
	shellcheck $(SCRIPTS)

##@ GENERATE

.PHONY: new_post
new_post: ## Create a new blog post (usage: make new_post NAME=my-post-title)
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) blog/$(NAME).md

.PHONY: new_doc
new_doc: ## Create a new doc page (usage: make new_doc NAME=section/my-page)
	cd $(SITE_DIR) && hugo new $(HUGO_FLAGS) docs/$(NAME).md

##@ CI

.PHONY: check_all
check_all: check_syntax check_lint ## Run every static check

.PHONY: ci
ci: check_all test ## Run the checks CI runs

.PHONY: clean
clean: ## Remove the generated public/ directory
	rm -rf $(PUBLIC)
