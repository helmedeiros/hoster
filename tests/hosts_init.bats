#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  HOST_DEFAULT_FOLDER=".hosts"
  TMPDIR_TEST="$(mktemp -d)"
  cd "$TMPDIR_TEST"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_init creates .hosts folder when absent" {
  hosts_init
  [ -d "$TMPDIR_TEST/.hosts" ]
}

@test "hosts_init creates the four environment host files" {
  hosts_init
  [ -f "$TMPDIR_TEST/.hosts/hosts.lcl" ]
  [ -f "$TMPDIR_TEST/.hosts/hosts.dev" ]
  [ -f "$TMPDIR_TEST/.hosts/hosts.hml" ]
  [ -f "$TMPDIR_TEST/.hosts/hosts.prd" ]
}

@test "hosts_init reports initialization message" {
  run hosts_init
  [[ "$output" == *"Initialized empty Hosts repository"* ]]
}

@test "hosts_init reinitializes when .hosts already exists" {
  mkdir "$TMPDIR_TEST/.hosts"
  run hosts_init
  [[ "$output" == *"Reinitialized Hosts repository"* ]]
}
