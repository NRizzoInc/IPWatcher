# Simple Makefile Wrapper around bash scripts

all: update

.PHONY: build
build: build-release.sh
	@bash build-release.sh

.PHONY: install
install: install.sh
	@bash install.sh

.PHONY: update
update: install.sh
	@bash install.sh --update

.PHONY: run
run: IPWatcher.sh
	@sudo bash IPWatcher.sh --watch 60

.PHONY: config configure
config configure: configure.sh
	@bash ./configure.sh --help

.PHONY: help
help:
	@sudo bash IPWatcher.sh --help
