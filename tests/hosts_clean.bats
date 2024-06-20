#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  PROJECT_NAME="bats-project"
  # Override HOST_FILE so the test does not touch the real system file.
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  : > "$HOST_FILE"
  ENVIRONMENT="dev"
  # Stub sudo so the suite never prompts and writes happen as the user.
  sudo() { "$@"; }
  export -f sudo
  cd "$TMPDIR_TEST"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_clean is a no-op when no project block exists" {
  run hosts_clean
  [ "$status" -eq 0 ]
  [[ "$output" == *"Nothing to clean"* ]]
}

@test "hosts_clean leaves the host file untouched when nothing matches" {
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  before="$(cat "$HOST_FILE")"
  hosts_clean
  after="$(cat "$HOST_FILE")"
  [ "$before" = "$after" ]
}

@test "hosts_clean sets FILE for the requested environment" {
  hosts_clean
  [ "$FILE" = "hosts.dev" ]
}

@test "hosts_clean removes the matching block from the host file" {
  {
    echo "127.0.0.1 localhost"
    echo "##<bats-project-dev>##"
    echo "10.0.0.1 dev.example.com"
    echo "##</bats-project-dev>##"
    echo "192.168.1.1 other.local"
  } > "$HOST_FILE"

  hosts_clean

  run cat "$HOST_FILE"
  [[ "$output" == *"127.0.0.1 localhost"* ]]
  [[ "$output" == *"192.168.1.1 other.local"* ]]
  [[ "$output" != *"bats-project-dev"* ]]
  [[ "$output" != *"dev.example.com"* ]]
}

@test "hosts_clean leaves other-project blocks untouched" {
  {
    echo "##<bats-project-dev>##"
    echo "10.0.0.1 mine.local"
    echo "##</bats-project-dev>##"
    echo "##<other-project-dev>##"
    echo "10.0.0.2 theirs.local"
    echo "##</other-project-dev>##"
  } > "$HOST_FILE"

  hosts_clean

  run cat "$HOST_FILE"
  [[ "$output" == *"other-project-dev"* ]]
  [[ "$output" == *"theirs.local"* ]]
  [[ "$output" != *"bats-project-dev"* ]]
}
