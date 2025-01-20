#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../adapters/term.sh
  source "$PROJECT_ROOT/adapters/term.sh"
}

@test "hoster_log emits nothing when VERBOSE=false" {
  VERBOSE="false"
  run hoster_log "hello"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hoster_log emits nothing when VERBOSE is unset" {
  unset VERBOSE
  run hoster_log "hello"
  [ -z "$output" ]
}

@test "hoster_log echoes when VERBOSE=true" {
  VERBOSE="true"
  run hoster_log "hello"
  [[ "$output" == "hello" ]]
}

@test "hoster_log writes to stderr, not stdout" {
  VERBOSE="true"
  run bash -c "VERBOSE=true; source '$PROJECT_ROOT/adapters/term.sh'; hoster_log 'stderr only' 2>/dev/null"
  [ -z "$output" ]
}
