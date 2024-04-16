#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../builtin/defaults.sh
  source "$PROJECT_ROOT/builtin/defaults.sh"
}

@test "define_defaults sets editor, file path and file from arguments" {
  define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  [ "$DEFAULT_IDE" = "sublime" ]
  [ "$FILE_PATH" = "/private/etc/" ]
  [ "$FILE" = "Hosts" ]
}

@test "define_defaults sets network from argument" {
  define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  [ "$network" = "Wi-Fi" ]
}

@test "define_defaults sets HOST_PATH/HOST_FILE/HOST_DEFAULT_FOLDER constants" {
  define_defaults "vim" "/etc/" "hosts" "eth0"
  [ "$HOST_PATH" = "/private/etc" ]
  [ "$HOST_FILE" = "/private/etc/Hosts" ]
  [ "$HOST_DEFAULT_FOLDER" = ".hosts" ]
}
