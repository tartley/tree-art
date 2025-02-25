
help: ## Show this help.
	@# Optionally add 'sort' before 'awk'
	@grep -E '^[^_][a-zA-Z_\/\.%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%+14s\033[0m %s\n", $$1, $$2}'
.PHONY: help

name=tree-art

## System dependencies

apt-packages:
	sudo apt install -y imagemagick
.PHONY: apt-packages

py-packages: ve-install-dev
.PHONY: py-packages

setup: apt-packages py-packages ## Install dependencies (requires sudo password)

## Virtualenv

ve=${HOME}/.virtualenvs/${name}
pip=${ve}/bin/pip
python=${ve}/bin/python3
pytest=${ve}/bin/pytest

ve-clean: ## Delete virtualenv & temporary files.
	rm -rf build dist MANIFEST tags *.egg-info *.spec "${ve}"
	find . -name __pycache__ -type d | xargs rm -rf
.PHONY: ve-clean

${ve}:
	python3 -m venv ${ve}
	${pip} -q install -U pip # setuptools wheel

requirements/runtime: requirements/runtime.in
	$(MAKE) ve-clean ${ve}
	${pip} -q install -U -r requirements/runtime.in
	${pip} freeze >requirements/runtime

ve-req-run: requirements/runtime ## Pinned runtime requirements
.PHONY: ve-req-run

requirements/dev: requirements/runtime requirements/dev.in
	$(MAKE) ve-clean ${ve}
	${pip} -q install -U -r requirements/dev.in -r requirements/runtime
	${pip} freeze >requirements/dev

ve-req-dev: requirements/dev ## Pinned dev requirements
.PHONY: ve-req-dev

ve-install-run: requirements/run ${ve} ## Create venv & pip install packages for runtime
	${pip} -q install -r requirements/run
.PHONY: ve-install-run

ve-install-dev: requirements/dev ${ve} ## Create venv & pip install packages for runtime & dev
	${pip} -q install -r requirements/dev
.PHONY: ve-install-dev

ve-update: ## Update to latest version of all dependencies
	rm -f requirements/dev requirements/runtime
	$(MAKE) requirements/runtime requirements/dev
.PHONY: ve-update

## Development

dev-tags: ## Create tags
	ctags -R --languages=python .
.PHONY: dev-tags

dev-lint: ## Fix lint errors
	@ruff check -q --fix .
.PHONY: dev-lint

dev-format: ## Fix formatting errors
	@ruff format -q .
.PHONY: dev-format

dev-test: ## Run unit tests
	@${pytest} -q .
.PHONY: dev-test

dev-ci: lint format test ## Lint, Format and Test
.PHONY: dev-ci


## Creation of the output image

# Times shown in secs are to generate or convert an -i18 image (2^18 polygons),
# which is about the limit for interactive tasks on my laptop.
# Higher numbers cause my SVG viewers or conversion tools to barf.

clean: ## Delete generated files
	rm -f $(name).svg $(name).png $(name).webp $(name).lossy.webp
.PHONY: clean

svg: $(name).svg ## Generate the SVG
.PHONY: svg

$(name).svg: $(ve) $(name).py
	# 8 seconds
	$(python) tree-art.py -i18 -o $@


## Conversion of the output image

png: $(name).png ## Convert SVG to a PNG
.PHONY: png

%.png: %.svg
	# 9 seconds
	convert $< $@

webp: $(name).webp ## Convert PNG to a lossless webp
.PHONY: webp

%.webp: %.png
	convert $< -define webp:lossless=true $@

lossy: $(name).lossy.webp ## Convert PNG to a lossy webp
.PHONY: lossy

%.lossy.webp: %.png
	convert $< -define webp:lossless=false -quality 75 $@

all: lossy ## Make the final lossy output
.PHONY: all

