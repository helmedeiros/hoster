#!/usr/bin/env bats

load test_helper

@test "project root contains hoster.sh" {
  [ -f "$PROJECT_ROOT/hoster.sh" ]
}

@test "project root contains hoster.version" {
  [ -f "$PROJECT_ROOT/hoster.version" ]
}

@test "all builtin modules exist" {
  [ -f "$PROJECT_ROOT/builtin/defaults.sh" ]
  [ -f "$PROJECT_ROOT/builtin/handle_options.sh" ]
  [ -f "$PROJECT_ROOT/builtin/host_actions.sh" ]
  [ -f "$PROJECT_ROOT/builtin/host_apply.sh" ]
  [ -f "$PROJECT_ROOT/builtin/paths.sh" ]
}
