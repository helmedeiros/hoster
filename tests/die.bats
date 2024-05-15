#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
}

@test "die exits with status 1" {
  run die "boom"
  [ "$status" -eq 1 ]
}

@test "die writes the message to stderr" {
  run bash -c "source '$PROJECT_ROOT/commands.sh'; die 'something went wrong' 2>&1 1>/dev/null"
  [[ "$output" == *"ERROR: something went wrong"* ]]
}

@test "die preserves the ERROR prefix" {
  run die "x"
  [[ "$output" == *"ERROR: x"* ]]
}
