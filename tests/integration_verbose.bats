#!/usr/bin/env bats

load test_helper

@test "hoster --verbose --version succeeds" {
  run_hoster --verbose --version
  [ "$status" -eq 0 ]
}

@test "hoster -v --version succeeds" {
  run_hoster -v --version
  [ "$status" -eq 0 ]
}

@test "hoster --verbose --version prints the version" {
  run_hoster --verbose --version
  [[ "$output" == *"version"* ]]
}

@test "--verbose is consumed and does not become the command" {
  run_hoster --verbose
  # With only --verbose and nothing else, the loop ends with no COMMAND set,
  # so hoster falls through. Should still exit cleanly.
  [ "$status" -eq 0 ]
}

@test "--verbose before --help still shows help" {
  run_hoster --verbose --help
  [[ "$output" == *"add"* ]]
  [[ "$output" == *"init"* ]]
}
