#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
}

@test "define_ip accepts a valid IPv4 and sets ADD_IP" {
  define_ip "10.0.0.5"
  [ "$ADD_IP" = "10.0.0.5" ]
}

@test "define_ip prints status good for a valid IPv4" {
  run define_ip "192.168.1.1"
  [[ "$output" == *"good"* ]]
}

@test "define_ip dies on invalid IPv4" {
  run define_ip "999.0.0.1"
  [ "$status" -eq 1 ]
  [[ "$output" == *"INVALID IP"* ]]
}

@test "define_ip dies on non-numeric input" {
  run define_ip "not-an-ip"
  [ "$status" -eq 1 ]
}
