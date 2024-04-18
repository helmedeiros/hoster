#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
}

@test "cmd_set_environment dev → hosts.dev" {
  cmd_set_environment "dev"
  [ "$FILE" = "hosts.dev" ]
}

@test "cmd_set_environment hlg → hosts.hml" {
  cmd_set_environment "hlg"
  [ "$FILE" = "hosts.hml" ]
}

@test "cmd_set_environment lcl → hosts.lcl" {
  cmd_set_environment "lcl"
  [ "$FILE" = "hosts.lcl" ]
}

@test "cmd_set_environment prod → hosts.prd" {
  cmd_set_environment "prod"
  [ "$FILE" = "hosts.prd" ]
}

@test "cmd_set_environment leaves FILE unchanged for unknown env" {
  FILE="sentinel"
  cmd_set_environment "bogus"
  [ "$FILE" = "sentinel" ]
}
