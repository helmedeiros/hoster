#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../adapters/clock.sh
  source "$PROJECT_ROOT/adapters/clock.sh"
}

@test "clock_now_iso8601_utc emits 16 characters" {
  result="$(clock_now_iso8601_utc)"
  [ "${#result}" = "16" ]
}

@test "clock_now_iso8601_utc matches the YYYYMMDDTHHMMSSZ shape" {
  result="$(clock_now_iso8601_utc)"
  [[ "$result" =~ ^[0-9]{8}T[0-9]{6}Z$ ]]
}

@test "clock_now_iso8601_utc is filesystem-safe" {
  result="$(clock_now_iso8601_utc)"
  # No path separators, no dots, no colons, no whitespace.
  [[ "$result" != *"/"* ]]
  [[ "$result" != *"."* ]]
  [[ "$result" != *":"* ]]
  [[ "$result" != *" "* ]]
}
