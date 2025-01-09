#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../core/pure.sh
  source "$PROJECT_ROOT/core/pure.sh"
}

@test "env_to_filename dev → hosts.dev" {
  [ "$(env_to_filename dev)" = "hosts.dev" ]
}

@test "env_to_filename hlg → hosts.hml" {
  [ "$(env_to_filename hlg)" = "hosts.hml" ]
}

@test "env_to_filename lcl → hosts.lcl" {
  [ "$(env_to_filename lcl)" = "hosts.lcl" ]
}

@test "env_to_filename prod → hosts.prd" {
  [ "$(env_to_filename prod)" = "hosts.prd" ]
}

@test "env_to_filename emits empty for unknown env" {
  result="$(env_to_filename bogus)"
  [ -z "$result" ]
}

@test "env_to_filename emits empty for empty input" {
  result="$(env_to_filename "")"
  [ -z "$result" ]
}
