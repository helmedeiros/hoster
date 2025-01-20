#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../adapters/os.sh
  source "$PROJECT_ROOT/adapters/os.sh"
}

@test "hoster_os_is_macos true under darwin*" {
  OSTYPE="darwin22.0"
  run hoster_os_is_macos
  [ "$status" -eq 0 ]
}

@test "hoster_os_is_macos false under linux-gnu" {
  OSTYPE="linux-gnu"
  run hoster_os_is_macos
  [ "$status" -ne 0 ]
}

@test "hoster_os_is_linux true under linux-gnu" {
  OSTYPE="linux-gnu"
  run hoster_os_is_linux
  [ "$status" -eq 0 ]
}

@test "hoster_os_is_linux false under darwin*" {
  OSTYPE="darwin22.0"
  run hoster_os_is_linux
  [ "$status" -ne 0 ]
}

@test "hoster_os_is_windows true under msys" {
  OSTYPE="msys"
  run hoster_os_is_windows
  [ "$status" -eq 0 ]
}

@test "hoster_os_is_windows true under mingw32" {
  OSTYPE="mingw32"
  run hoster_os_is_windows
  [ "$status" -eq 0 ]
}

@test "hoster_os_host_file returns /private/etc/hosts on macOS" {
  OSTYPE="darwin22.0"
  result="$(hoster_os_host_file)"
  [ "$result" = "/private/etc/hosts" ]
}

@test "hoster_os_host_file returns /etc/hosts on Linux" {
  OSTYPE="linux-gnu"
  result="$(hoster_os_host_file)"
  [ "$result" = "/etc/hosts" ]
}

@test "hoster_os_host_file returns Windows path under msys" {
  OSTYPE="msys"
  result="$(hoster_os_host_file)"
  [ "$result" = "/c/Windows/System32/drivers/etc/hosts" ]
}

@test "hoster_os_host_file falls back to /etc/hosts under unknown OS" {
  OSTYPE="solaris"
  result="$(hoster_os_host_file)"
  [ "$result" = "/etc/hosts" ]
}
