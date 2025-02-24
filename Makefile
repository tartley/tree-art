
help: ## Show this help.
	@# Optionally add 'sort' before 'awk'
	@grep -E '^[^_][a-zA-Z_\/\.%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'
.PHONY: help

## Virtualenv

name=tree-art
ve=${HOME}/.virtualenvs/${name}
pip=${ve}/bin/pip
python=${ve}/bin/python3
pytest=${ve}/bin/pytest

clean-ve: ## Delete virtualenv & temporary files.
	rm -rf build dist MANIFEST tags *.egg-info *.spec "${ve}"
	find . -name __pycache__ -type d | xargs rm -rf
.PHONY: clean-ve

${ve}:
	python3 -m venv ${ve}
	${pip} -q install -U pip # setuptools wheel

requirements/runtime: requirements/runtime.in ## Pinned runtime requirements.
	$(MAKE) clean-ve ${ve}
	${pip} -q install -U -r requirements/runtime.in
	${pip} freeze >requirements/runtime

requirements/dev: requirements/runtime requirements/dev.in ## Pinned dev requirements.
	$(MAKE) clean-ve ${ve}
	${pip} -q install -U -r requirements/dev.in -r requirements/runtime
	${pip} freeze >requirements/dev

populated-ve: requirements/dev ${ve} ## Create venv & pip install packages for runtime & dev
	${pip} -q install -r requirements/dev
.PHONY: populated-ve

update: ## Update to latest version of all dependencies
	rm -f requirements/dev requirements/runtime
	$(MAKE) requirements/runtime requirements/dev
.PHONY: update

## Development

tags: ## Create tags
	ctags -R --languages=python .
.PHONY: tags

lint: ## Fix lint errors
	@ruff check -q --fix .
.PHONY: lint

format: ## Fix formatting errors
	@ruff format -q .
.PHONY: format

test: ## Run unit tests
	@${pytest} -q .
.PHONY: test

ci: lint format test ## Lint, Format and Test
.PHONY: ci

