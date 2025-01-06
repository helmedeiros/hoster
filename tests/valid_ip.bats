#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../core/pure.sh
  source "$PROJECT_ROOT/core/pure.sh"
}

@test "valid_ip accepts a standard IPv4" {
  run valid_ip "10.0.0.1"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts boundary 0.0.0.0" {
  run valid_ip "0.0.0.0"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts boundary 255.255.255.255" {
  run valid_ip "255.255.255.255"
  [ "$status" -eq 0 ]
}

@test "valid_ip rejects octet > 255" {
  run valid_ip "256.0.0.1"
  [ "$status" -ne 0 ]
}

@test "valid_ip rejects malformed (3 octets)" {
  run valid_ip "10.0.0"
  [ "$status" -ne 0 ]
}

@test "valid_ip rejects non-numeric input" {
  run valid_ip "abc.def.ghi.jkl"
  [ "$status" -ne 0 ]
}

@test "valid_ip rejects empty string" {
  run valid_ip ""
  [ "$status" -ne 0 ]
}
