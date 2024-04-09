#!/usr/bin/env bash
#
# Shared helpers for the bats test suite.

# Absolute path to the repository root.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT

# Run a hoster subcommand from a clean working directory.
run_hoster() {
  run "$PROJECT_ROOT/hoster.sh" "$@"
}
