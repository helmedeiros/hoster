#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  TMPDIR_TEST="$(mktemp -d)"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  PROJECT_NAME="bats-project"
  ENVIRONMENT="dev"
  # find_occurrence uses sudo; stub it for tests so we do not prompt.
  sudo() { "$@"; }
  export -f sudo
  cd "$TMPDIR_TEST"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "find_occurrence sets found=false on empty host file" {
  : > "$HOST_FILE"
  find_occurrence
  [ "$found" = "false" ]
}

@test "find_occurrence sets found=true when project block present" {
  {
    echo "127.0.0.1 localhost"
    echo "##<bats-project-dev>##"
    echo "10.0.0.1 dev.example.com"
    echo "##</bats-project-dev>##"
  } > "$HOST_FILE"
  find_occurrence
  [ "$found" = "true" ]
}

@test "find_occurrence reports not-found message for missing block" {
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  run find_occurrence
  [[ "$output" == *"wasn't found"* ]]
}

@test "find_occurrence cleans up its temp file" {
  : > "$HOST_FILE"
  find_occurrence
  [ ! -f "Hosts.out.tmp" ]
}
