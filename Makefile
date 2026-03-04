INSTALL_DIR ?= $(HOME)/.local/bin
CONFIG_PATH ?= $(HOME)/.mediacleanup.toml
DEFAULT_MEDIA_DIR ?= $(HOME)/Movies/NewMedia
ALLOWED_EXT := mp4 mkv avi mov flv wmv mpg mpeg webm m4v srt DS_Store
INSTALL_TARGET := $(INSTALL_DIR)/mediacleanup
PREREQ_CMDS := python3 find mv awk sed tr mkdir rmdir touch mktemp
VENV_DIR ?= .venv
VENV_PYTHON := $(VENV_DIR)/bin/python

.PHONY: help install check-prereq uninstall lint test ensure-venv ensure-test-deps
.DEFAULT_GOAL := help

help:
	@printf "Usage: make <target>\n\n"
	@printf "Targets:\n"
	@printf "  help          Show this help (default)\n"
	@printf "  install       Copy mediacleanup.py and create ~/.mediacleanup.toml (interactive)\n"
	@printf "  check-prereq  Assert required tools are available\n"
	@printf "  lint          Run Python lint checks\n"
	@printf "  test          Run automated tests\n"
	@printf "  uninstall     Remove the installed mediacleanup binary\n"

install:
	@set -eu; \
	ALLOWED_EXT="$(ALLOWED_EXT)" \
	INSTALL_DIR="$(INSTALL_DIR)" \
	CONFIG_PATH="$(CONFIG_PATH)" \
	DEFAULT_MEDIA_DIR="$(DEFAULT_MEDIA_DIR)" \
	python3 scripts/install_mediacleanup.py

check-prereq:
	@set -eu; \
	missing=0; \
	for cmd in $(PREREQ_CMDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			echo "Missing prerequisite: $$cmd"; \
			missing=$$((missing + 1)); \
		fi; \
	done; \
	if [ $$missing -gt 0 ]; then \
		echo "Install the missing dependencies and rerun."; \
		exit 1; \
	fi; \
	echo "All prerequisites are satisfied."

ensure-venv:
	@set -eu; \
	if [ ! -x "$(VENV_PYTHON)" ]; then \
		python3 -m venv "$(VENV_DIR)"; \
	fi

ensure-test-deps: ensure-venv
	@set -eu; \
	"$(VENV_PYTHON)" -m pip install -q pytest

lint:
	@set -eu; \
	python3 -m py_compile mediacleanup.py src/mediacleanup.py scripts/install_mediacleanup.py; \
	markdownlint README.md AGENTS.md CHANGELOG.md specs/005-python-migration-cleanup/*.md

test: ensure-test-deps
	@set -eu; \
	"$(VENV_PYTHON)" -m pytest -q

uninstall:
	@set -eu; \
	target="$(INSTALL_TARGET)"; \
	if [ -f "$$target" ]; then \
		rm -f "$$target"; \
		echo "Removed $$target"; \
	else \
		echo "$$target not found, nothing to remove."; \
	fi; \
	echo "mediacleanup uninstalled (config left untouched at $(CONFIG_PATH))."
