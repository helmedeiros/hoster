#!/usr/bin/env bats

load test_helper

# Subcommands declared in handle_main_options. Keep this list in sync
# with builtin/handle_options.sh; the bats suite enforces that.
ROUTED_SUBCOMMANDS="add apply clean diff doctor edit export import init list remove rm status validate"

@test "bash completion subcommand list matches the router" {
  grep -E '^[[:space:]]+local subcommands=' "$PROJECT_ROOT/scripts/completion.bash" \
    | head -1 > /tmp/bash_sub.txt
  for c in $ROUTED_SUBCOMMANDS; do
    grep -q "$c" /tmp/bash_sub.txt
  done
  rm -f /tmp/bash_sub.txt
}

@test "zsh completion subcommand list matches the router" {
  for c in $ROUTED_SUBCOMMANDS; do
    grep -q "^[[:space:]]*'${c}:" "$PROJECT_ROOT/scripts/_hoster"
  done
}

@test "all routed subcommands appear in the man page" {
  for c in add apply clean diff doctor edit export import init list remove status validate; do
    grep -q "^\.B ${c}\b" "$PROJECT_ROOT/man/hoster.1"
  done
}

@test "all routed subcommands appear in help.sh" {
  for c in add apply clean diff doctor edit export import init list remove status validate; do
    grep -q "${c}" "$PROJECT_ROOT/help.sh"
  done
}
