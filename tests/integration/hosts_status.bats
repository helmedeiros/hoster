#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  PROJECT_NAME="bats-project"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_status reports nothing when no block is applied" {
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  run hosts_status
  [ "$status" -eq 0 ]
  [[ "$output" == *"No bats-project block applied"* ]]
}

@test "hosts_status reports the one applied environment" {
  {
    echo "##<bats-project-dev>##"
    echo "10.0.0.1 dev.example.com"
    echo "##</bats-project-dev>##"
  } > "$HOST_FILE"

  run hosts_status
  [[ "$output" == *"bats-project applied environments:"* ]]
  [[ "$output" == *"dev"* ]]
}

@test "hosts_status lists multiple applied environments" {
  {
    echo "##<bats-project-dev>##"
    echo "10.0.0.1 dev.example.com"
    echo "##</bats-project-dev>##"
    echo "##<bats-project-prd>##"
    echo "10.2.0.1 prd.example.com"
    echo "##</bats-project-prd>##"
  } > "$HOST_FILE"

  run hosts_status
  [[ "$output" == *"dev"* ]]
  [[ "$output" == *"prd"* ]]
}

@test "hosts_status ignores other projects' blocks" {
  {
    echo "##<other-project-dev>##"
    echo "10.5.0.1 theirs.local"
    echo "##</other-project-dev>##"
  } > "$HOST_FILE"

  run hosts_status
  [[ "$output" == *"No bats-project block applied"* ]]
}
