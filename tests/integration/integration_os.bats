#!/usr/bin/env bats

load ../test_helper

@test "hoster runs end-to-end on the current OS" {
  run_hoster --version
  [ "$status" -eq 0 ]
}

@test "HOST_FILE matches the OS-resolved host file path" {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  [ "$HOST_FILE" = "$(hoster_os_host_file)" ]
}

@test "HOST_FILE under forced Linux is /etc/hosts" {
  OSTYPE="linux-gnu"
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  [ "$HOST_FILE" = "/etc/hosts" ]
}

@test "HOST_FILE under forced macOS is /private/etc/hosts" {
  OSTYPE="darwin22.0"
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  [ "$HOST_FILE" = "/private/etc/hosts" ]
}
