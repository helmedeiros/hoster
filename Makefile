SHELL := /bin/bash

SH_FILES := $(wildcard *.sh) $(wildcard builtin/*.sh)

.PHONY: help lint test all clean

help:
	@echo "Targets:"
	@echo "  lint   - run shellcheck on all shell scripts"
	@echo "  test   - run bats test suite"
	@echo "  all    - lint + test"
	@echo "  clean  - remove build artifacts"

lint:
	shellcheck $(SH_FILES)

test:
	bats tests/

all: lint test

clean:
	rm -rf target/ bin/
