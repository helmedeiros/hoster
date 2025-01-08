#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../core/pure.sh
  source "$PROJECT_ROOT/core/pure.sh"
}

@test "parse_host_line classifies blank as blank" {
  [ "$(parse_host_line "")" = "blank" ]
}

@test "parse_host_line classifies whitespace as blank" {
  [ "$(parse_host_line "   ")" = "blank" ]
}

@test "parse_host_line classifies a # line as comment with original verbatim" {
  result="$(parse_host_line "# api section")"
  [ "$result" = "comment # api section" ]
}

@test "parse_host_line preserves leading whitespace on comments" {
  result="$(parse_host_line "   # indented")"
  [ "$result" = "comment    # indented" ]
}

@test "parse_host_line classifies an entry" {
  result="$(parse_host_line "10.0.0.1 dev.example.com")"
  [ "$result" = "entry 10.0.0.1 dev.example.com" ]
}

@test "parse_host_line ignores trailing fields on an entry" {
  result="$(parse_host_line "10.0.0.1 dev.example.com  # inline")"
  [ "$result" = "entry 10.0.0.1 dev.example.com" ]
}

@test "parse_host_line reports a single-field line as malformed" {
  result="$(parse_host_line "missingsecond")"
  [ "$result" = "malformed missingsecond" ]
}
