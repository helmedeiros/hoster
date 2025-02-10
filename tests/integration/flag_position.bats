#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "add accepts the env flag after the IP and host" {
  add_host add 10.0.0.1 dev.example.com --dev
  [ "$ADD_IP" = "10.0.0.1" ]
  [ "$ADD_HOST" = "dev.example.com" ]
  [ "$ENVIRONMENT" = "dev" ]
}

@test "add accepts the env flag before the IP and host" {
  add_host add --dev 10.0.0.1 dev.example.com
  [ "$ADD_IP" = "10.0.0.1" ]
  [ "$ADD_HOST" = "dev.example.com" ]
  [ "$ENVIRONMENT" = "dev" ]
}

@test "add accepts the env flag between the IP and host" {
  add_host add 10.0.0.1 --dev dev.example.com
  [ "$ADD_IP" = "10.0.0.1" ]
  [ "$ADD_HOST" = "dev.example.com" ]
  [ "$ENVIRONMENT" = "dev" ]
}

@test "remove accepts the env flag after the hostname" {
  remove_host remove dev.example.com --dev
  [ "$REMOVE_HOST" = "dev.example.com" ]
  [ "$ENVIRONMENT" = "dev" ]
}

@test "remove accepts the env flag before the hostname" {
  remove_host remove --dev dev.example.com
  [ "$REMOVE_HOST" = "dev.example.com" ]
  [ "$ENVIRONMENT" = "dev" ]
}
