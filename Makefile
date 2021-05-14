MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

include Makefile.vars.mk

.PHONY: help
help: ## Show this help
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "(: ).*?## "}; {gsub(/\\:/,":", $$1)}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: all
all: lint

.PHONY: lint
lint: lint_jsonnet lint_yaml lint_adoc ## All-in-one linting

.PHONY: lint_jsonnet
lint_jsonnet: $(JSONNET_FILES) ## Lint jsonnet files
	$(JSONNET_DOCKER) $(JSONNETFMT_ARGS) --test -- $?

.PHONY: lint_yaml
lint_yaml: $(YAML_FILES) ## Lint yaml files
	$(YAMLLINT_DOCKER) -f parsable -c $(YAMLLINT_CONFIG) $(YAMLLINT_ARGS) -- $?

.PHONY: lint_adoc
lint_adoc:
	$(VALE_CMD) $(VALE_ARGS)

.PHONY: format
format: format_jsonnet ## All-in-one formatting

.PHONY: format_jsonnet
format_jsonnet: $(JSONNET_FILES) ## Format jsonnet files
	$(JSONNET_DOCKER) $(JSONNETFMT_ARGS) -- $?

.PHONY: compile
.compile:
	$(COMMODORE_CMD)

.PHONY: test-builtin
test-builtin: commodore_args = -f tests/builtin.yml
test-builtin: .compile ## Compile component with builtin database provider

.PHONY: test-external
test-external: commodore_args = -f tests/external.yml
test-external: .compile ## Compile component with external database provider

.PHONY: clean
clean: ## Clean the project
	rm -rf compiled dependencies vendor helmcharts jsonnetfile*.json || true
