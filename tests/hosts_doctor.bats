#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
}

@test "hosts_doctor exits 0 on the dev box" {
  # All required checks should pass in the working tree.
  run hosts_doctor
  [ "$status" -eq 0 ]
}

@test "hosts_doctor reports a Runtime section" {
  run hosts_doctor
  [[ "$output" == *"Runtime:"* ]]
}

@test "hosts_doctor reports a Dependencies section" {
  run hosts_doctor
  [[ "$output" == *"Dependencies:"* ]]
  [[ "$output" == *"jq"* ]]
}

@test "hosts_doctor reports an Install section" {
  run hosts_doctor
  [[ "$output" == *"Install:"* ]]
  [[ "$output" == *"hoster on PATH"* ]]
}

@test "hosts_doctor exit summary mentions \"checks passed\" when clean" {
  run hosts_doctor
  [[ "$output" == *"checks passed"* ]]
}

@test "hosts_doctor exits 1 when a required check fails" {
  # Force the host-file-readable check to fail by pointing OSTYPE at
  # an unknown OS so hoster_os_host_file returns /etc/hosts which is
  # readable -- so we need a different forcing. Use a subshell that
  # overrides hoster_os_host_file to a bogus path.
  hoster_os_host_file() { echo "/does/not/exist/hosts"; }
  export -f hoster_os_host_file

  run bash -c 'source "'"$PROJECT_ROOT"'/commands.sh"; hoster_os_host_file() { echo "/does/not/exist/hosts"; }; hosts_doctor'
  [ "$status" -eq 1 ]
  [[ "$output" == *"required check(s) failed"* ]]
}
