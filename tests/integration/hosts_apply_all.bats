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
  sudo() { "$@"; }
  export -f sudo
  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"
  cd "$TMPDIR_TEST"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_apply_all reports zero when nothing is populated" {
  run hosts_apply_all
  [[ "$output" == *"Applied 0 environment(s)"* ]]
}

@test "hosts_apply_all skips empty env files" {
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"

  run hosts_apply_all
  [[ "$output" == *"Applied 1 environment(s)"* ]]
  run cat "$HOST_FILE"
  [[ "$output" == *"##<bats-project-dev>##"* ]]
  [[ "$output" != *"##<bats-project-lcl>##"* ]]
}

@test "hosts_apply_all writes a block per populated env" {
  echo "127.0.0.1 lcl.example.com" > "$TMPDIR_TEST/hosts.lcl"
  echo "10.0.0.1 dev.example.com"  > "$TMPDIR_TEST/hosts.dev"
  echo "10.2.0.1 prd.example.com"  > "$TMPDIR_TEST/hosts.prd"

  run hosts_apply_all
  [[ "$output" == *"Applied 3 environment(s)"* ]]
  run cat "$HOST_FILE"
  # Markers use the ENVIRONMENT name (lcl/dev/hlg/prod), not the
  # FILE suffix (.lcl/.dev/.hml/.prd).
  [[ "$output" == *"##<bats-project-lcl>##"* ]]
  [[ "$output" == *"##<bats-project-dev>##"* ]]
  [[ "$output" == *"##<bats-project-prod>##"* ]]
  [[ "$output" != *"##<bats-project-hlg>##"* ]]
}

@test "hosts_apply routes --all-equivalent ENVIRONMENT=all to apply_all" {
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"
  ENVIRONMENT="all"

  run hosts_apply
  [[ "$output" == *"Applied"* ]]
}
