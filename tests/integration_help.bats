#!/usr/bin/env bats

load test_helper

@test "hoster --help exits successfully" {
  run_hoster --help
  [ "$status" -eq 0 ]
}

@test "hoster --help lists the common commands" {
  run_hoster --help
  [[ "$output" == *"add"* ]]
  [[ "$output" == *"apply"* ]]
  [[ "$output" == *"clean"* ]]
  [[ "$output" == *"diff"* ]]
  [[ "$output" == *"edit"* ]]
  [[ "$output" == *"export"* ]]
  [[ "$output" == *"import"* ]]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"list"* ]]
  [[ "$output" == *"remove"* ]]
  [[ "$output" == *"status"* ]]
  [[ "$output" == *"validate"* ]]
  [[ "$output" == *"doctor"* ]]
}

@test "hoster --H is an alias for --help" {
  run_hoster --H
  [ "$status" -eq 0 ]
  [[ "$output" == *"add"* ]]
}
