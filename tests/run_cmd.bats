#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
}

@test "run_cmd executes a successful command quietly" {
  run run_cmd "true"
  [ "$status" -eq 0 ]
}

@test "run_cmd echoes the command name when run with a single argument" {
  run run_cmd "true"
  [[ "$output" == *"Running: true"* ]]
}

@test "run_cmd suppresses the banner when called with a second argument" {
  run run_cmd "true" "silent"
  [[ "$output" != *"Running: true"* ]]
}

@test "run_cmd exits 1 on failing command" {
  run run_cmd "false"
  [ "$status" -eq 1 ]
}

@test "run_cmd prints command failed message on failure" {
  run run_cmd "false"
  [[ "$output" == *"command failed: false"* ]]
}
