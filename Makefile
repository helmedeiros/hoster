SHELL := /bin/bash

SH_FILES := $(wildcard *.sh) $(wildcard builtin/*.sh) $(wildcard scripts/*.sh) $(wildcard scripts/*.bash)

COMPLETION_DIR ?= $(if $(shell test -d /opt/homebrew/etc/bash_completion.d && echo yes),/opt/homebrew/etc/bash_completion.d,/etc/bash_completion.d)
ZSH_COMPLETION_DIR ?= $(if $(shell test -d /opt/homebrew/share/zsh/site-functions && echo yes),/opt/homebrew/share/zsh/site-functions,/usr/local/share/zsh/site-functions)
MAN_DIR ?= $(if $(shell test -d /opt/homebrew/share/man/man1 && echo yes),/opt/homebrew/share/man/man1,/usr/local/share/man/man1)

.PHONY: help lint test all clean install-completion install-zsh-completion install-man install-hooks

help:
	@echo "Targets:"
	@echo "  lint                    - run shellcheck on all shell scripts"
	@echo "  test                    - run bats test suite"
	@echo "  all                     - lint + test"
	@echo "  clean                   - remove build artifacts"
	@echo "  install-completion      - install scripts/completion.bash into \$$COMPLETION_DIR"
	@echo "                            (default: $(COMPLETION_DIR))"
	@echo "  install-zsh-completion  - install scripts/_hoster into \$$ZSH_COMPLETION_DIR"
	@echo "                            (default: $(ZSH_COMPLETION_DIR))"
	@echo "  install-man             - install man/hoster.1 into \$$MAN_DIR"
	@echo "                            (default: $(MAN_DIR))"
	@echo "  install-hooks           - install scripts/install-hooks.sh's pre-commit"
	@echo "                            hook into .git/hooks (runs make all on commit)"

lint:
	shellcheck -x $(SH_FILES)

test:
	bats tests/

all: lint test

clean:
	rm -rf target/ bin/

install-completion:
	install -d "$(COMPLETION_DIR)"
	install -m 0644 scripts/completion.bash "$(COMPLETION_DIR)/hoster"
	@echo "Installed bash completion to $(COMPLETION_DIR)/hoster"
	@echo "Open a new shell or source the file to activate."

install-zsh-completion:
	install -d "$(ZSH_COMPLETION_DIR)"
	install -m 0644 scripts/_hoster "$(ZSH_COMPLETION_DIR)/_hoster"
	@echo "Installed zsh completion to $(ZSH_COMPLETION_DIR)/_hoster"
	@echo "Reload your shell or run: autoload -Uz compinit && compinit"

install-man:
	install -d "$(MAN_DIR)"
	install -m 0644 man/hoster.1 "$(MAN_DIR)/hoster.1"
	@echo "Installed man page to $(MAN_DIR)/hoster.1"
	@echo "Try: man hoster"

install-hooks:
	scripts/install-hooks.sh
