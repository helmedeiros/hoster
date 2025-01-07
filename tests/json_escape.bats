#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../core/pure.sh
  source "$PROJECT_ROOT/core/pure.sh"
}

@test "json_escape leaves plain ASCII untouched" {
  result="$(json_escape "hello world")"
  [ "$result" = "hello world" ]
}

@test "json_escape escapes a double quote" {
  result="$(json_escape 'say "hi"')"
  [ "$result" = 'say \"hi\"' ]
}

@test "json_escape escapes a backslash" {
  result="$(json_escape 'a\b')"
  [ "$result" = 'a\\b' ]
}

@test "json_escape handles both at once" {
  result="$(json_escape 'a\b"c')"
  [ "$result" = 'a\\b\"c' ]
}

@test "json_escape emits empty for empty input" {
  result="$(json_escape "")"
  [ -z "$result" ]
}
