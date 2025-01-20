#!/usr/bin/env bats

load ../test_helper

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

@test "define_defaults resolves HOST_FILE from os.sh and HOST_PATH from it" {
  OSTYPE="linux-gnu"
  define_defaults "vim" "/etc/" "hosts" "eth0"
  [ "$HOST_FILE" = "/etc/hosts" ]
  [ "$HOST_PATH" = "/etc" ]
  [ "$HOST_DEFAULT_FOLDER" = ".hosts" ]
}

@test "define_defaults resolves HOST_FILE on macOS" {
  OSTYPE="darwin22.0"
  define_defaults "vim" "/etc/" "hosts" "eth0"
  [ "$HOST_FILE" = "/private/etc/hosts" ]
  [ "$HOST_PATH" = "/private/etc" ]
}
