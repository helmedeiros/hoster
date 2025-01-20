#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  COMMAND=""
}

@test "handle_main_options --version sets COMMAND=VERSION" {
  handle_main_options "--version"
  [ "$COMMAND" = "VERSION" ]
}

@test "handle_main_options --V sets COMMAND=VERSION" {
  handle_main_options "--V"
  [ "$COMMAND" = "VERSION" ]
}

@test "handle_main_options --help sets COMMAND=HELP" {
  handle_main_options "--help"
  [ "$COMMAND" = "HELP" ]
}

@test "handle_main_options --H sets COMMAND=HELP" {
  handle_main_options "--H"
  [ "$COMMAND" = "HELP" ]
}

@test "handle_main_options init sets COMMAND=INIT" {
  handle_main_options "init"
  [ "$COMMAND" = "INIT" ]
}

@test "handle_main_options i sets COMMAND=INIT" {
  handle_main_options "i"
  [ "$COMMAND" = "INIT" ]
}

@test "handle_main_options clean sets COMMAND=CLEAN" {
  # cmd_top_level recurses up; stub it and the helpers it pairs with.
  cmd_top_level() { TOP_LEVEL_FOLDER="."; }
  cmd_project_name() { PROJECT_NAME="test-project"; }
  cmd_clean_host() { :; }
  handle_main_options "clean"
  [ "$COMMAND" = "CLEAN" ]
}

@test "handle_main_options reports unknown command" {
  run bash -c "source '$PROJECT_ROOT/commands.sh' && handle_main_options bogus"
  [[ "$output" == *"'bogus' is not a"* ]]
  [[ "$output" == *"command"* ]]
}
