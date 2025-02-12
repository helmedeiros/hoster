#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults sublime /private/etc/ Hosts Wi-Fi
  TMPDIR_TEST="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "cmd_top_level finds .hosts in the current directory" {
  mkdir -p "$TMPDIR_TEST/proj/.hosts"
  cd "$TMPDIR_TEST/proj"
  cmd_top_level
  [ "$TOP_LEVEL_FOLDER" = "$TMPDIR_TEST/proj/.hosts" ]
}

@test "cmd_top_level walks up from a subdirectory" {
  mkdir -p "$TMPDIR_TEST/proj/.hosts" "$TMPDIR_TEST/proj/src/sub"
  cd "$TMPDIR_TEST/proj/src/sub"
  cmd_top_level
  [ "$TOP_LEVEL_FOLDER" = "$TMPDIR_TEST/proj/.hosts" ]
}

@test "cmd_top_level dies cleanly when no .hosts ancestor exists" {
  mkdir -p "$TMPDIR_TEST/lonely"
  cd "$TMPDIR_TEST/lonely"
  run cmd_top_level
  [ "$status" -ne 0 ]
  [[ "$output" == *"Not inside a hoster project"* ]]
}

@test "cmd_top_level does not mistake a nested project for a parent project" {
  # Two sibling projects under a non-project parent. From the parent,
  # cmd_top_level should fail -- not silently follow a child's .hosts.
  mkdir -p "$TMPDIR_TEST/multi/a/.hosts" "$TMPDIR_TEST/multi/b/.hosts"
  cd "$TMPDIR_TEST/multi"
  run cmd_top_level
  [ "$status" -ne 0 ]
  [[ "$output" == *"Not inside a hoster project"* ]]
}
