#!/usr/bin/env bats

load ../test_helper

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
}

@test "core and adapter modules exist" {
  [ -f "$PROJECT_ROOT/core/pure.sh" ]
  [ -f "$PROJECT_ROOT/adapters/term.sh" ]
  [ -f "$PROJECT_ROOT/adapters/clock.sh" ]
  [ -f "$PROJECT_ROOT/adapters/fs.sh" ]
  [ -f "$PROJECT_ROOT/adapters/sudo.sh" ]
  [ -f "$PROJECT_ROOT/adapters/json.sh" ]
  [ -f "$PROJECT_ROOT/adapters/os.sh" ]
}
