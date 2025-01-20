#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  PROJECT_NAME="bats-project"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  : > "$HOST_FILE"
  echo "10.2.0.1 prd.example.com" > "$TMPDIR_TEST/hosts.prd"
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"
  sudo() { "$@"; }
  export -f sudo
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "apply --prod without FORCE refuses and exits 1" {
  ENVIRONMENT="prod"
  FORCE="false"
  run hosts_apply
  [ "$status" -eq 1 ]
  [[ "$output" == *"Refusing to apply --prod without --force"* ]]
}

@test "apply --prod without FORCE does not touch HOST_FILE" {
  ENVIRONMENT="prod"
  FORCE="false"
  before="$(cat "$HOST_FILE")"
  run hosts_apply
  after="$(cat "$HOST_FILE")"
  [ "$before" = "$after" ]
}

@test "apply --prod with FORCE=true writes the prod block" {
  ENVIRONMENT="prod"
  FORCE="true"
  hosts_apply
  run cat "$HOST_FILE"
  [[ "$output" == *"##<bats-project-prod>##"* ]]
}

@test "apply --dev is unaffected by the prod guard" {
  ENVIRONMENT="dev"
  FORCE="false"
  hosts_apply
  run cat "$HOST_FILE"
  [[ "$output" == *"##<bats-project-dev>##"* ]]
}

@test "apply (no flag) still walks prod via apply_all" {
  ENVIRONMENT="all"
  FORCE="false"
  hosts_apply
  run cat "$HOST_FILE"
  # The guard sits inside the single-env branch, not apply_all.
  [[ "$output" == *"##<bats-project-prod>##"* ]]
}
