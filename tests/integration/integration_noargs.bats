#!/usr/bin/env bats

load ../test_helper

@test "hoster with no args prints usage" {
  run_hoster
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage:"* ]]
}

@test "hoster with no args lists common commands" {
  run_hoster
  [[ "$output" == *"add"* ]]
  [[ "$output" == *"edit"* ]]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"list"* ]]
}

@test "hoster with unknown command reports it" {
  run_hoster bogus-cmd
  [[ "$output" == *"'bogus-cmd' is not a"* ]]
}
