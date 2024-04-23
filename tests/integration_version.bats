#!/usr/bin/env bats

load test_helper

@test "hoster --version exits successfully" {
  run_hoster --version
  [ "$status" -eq 0 ]
}

@test "hoster --version prints the version from hoster.version" {
  expected="$(cat "$PROJECT_ROOT/hoster.version")"
  run_hoster --version
  [[ "$output" == *"$expected"* ]]
}

@test "hoster --V prints the version" {
  run_hoster --V
  [ "$status" -eq 0 ]
  [[ "$output" == *"version"* ]]
}
