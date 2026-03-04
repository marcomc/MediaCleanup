SHELL := /usr/bin/env bash

INSTALL_DIR ?= /usr/local/bin
CONFIG_PATH ?= $(HOME)/.mediacleanup.conf
DEFAULT_MEDIA_DIR ?= $(HOME)/Movies/NewMedia
ALLOWED_EXT := mp4 mkv avi mov flv wmv mpg mpeg webm m4v srt DS_Store
INSTALL_TARGET := $(INSTALL_DIR)/mediacleanup.sh
PREREQ_CMDS := bash find mv awk sed tr mkdir rmdir touch tput mktemp stat

.PHONY: help install check-prereq uninstall
.DEFAULT_GOAL := help

help:
	@printf "Usage: make <target>\n\n"
	@printf "Targets:\n"
	@printf "  help          Show this help (default)\n"
	@printf "  install       Copy mediacleanup.sh and create ~/.mediacleanup.conf (interactive)\n"
	@printf "  check-prereq  Assert required UNIX tools are available\n"
	@printf "  uninstall     Remove the installed mediacleanup binary\n"

install:
	@set -euo pipefail; \
	ALLOWED_EXT="$(ALLOWED_EXT)" \
	INSTALL_DIR="$(INSTALL_DIR)" \
	CONFIG_PATH="$(CONFIG_PATH)" \
	DEFAULT_MEDIA_DIR="$(DEFAULT_MEDIA_DIR)" \
	bash scripts/install-mediacleanup.sh

check-prereq:
	@set -euo pipefail; \
	missing=0; \
	for cmd in $(PREREQ_CMDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			echo "Missing prerequisite: $$cmd"; \
			missing=$$((missing + 1)); \
		fi; \
	done; \
	if [[ $$missing -gt 0 ]]; then \
		echo "Install the missing dependencies and rerun."; \
		exit 1; \
	fi; \
	echo "All prerequisites are satisfied."

uninstall:
	@set -euo pipefail; \
	target="$(INSTALL_TARGET)"; \
	if [[ -f "$$target" ]]; then \
		rm -f "$$target"; \
		echo "Removed $$target"; \
	else \
		echo "$$target not found, nothing to remove."; \
	fi; \
	echo "mediacleanup uninstalled (config left untouched at $(CONFIG_PATH))."
