#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  ENVIRONMENT="dev"
  FILE="hosts.dev"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "host_remove no-ops with message when env file is missing" {
  REMOVE_HOST="www.example.com"
  run host_remove
  [ "$status" -eq 0 ]
  [[ "$output" == *"No dev host file"* ]]
}

@test "host_remove no-ops with message when host is absent" {
  echo "10.0.0.1 other.example.com" > "$TOP_LEVEL_FOLDER/$FILE"
  REMOVE_HOST="www.example.com"
  run host_remove
  [ "$status" -eq 0 ]
  [[ "$output" == *"www.example.com not found"* ]]
}

@test "host_remove deletes the matching line" {
  {
    echo "10.0.0.1 www.example.com"
    echo "10.0.0.2 other.example.com"
  } > "$TOP_LEVEL_FOLDER/$FILE"

  REMOVE_HOST="www.example.com"
  host_remove

  run cat "$TOP_LEVEL_FOLDER/$FILE"
  [[ "$output" != *"www.example.com"* ]]
  [[ "$output" == *"other.example.com"* ]]
}

@test "host_remove confirms removal" {
  echo "10.0.0.1 www.example.com" > "$TOP_LEVEL_FOLDER/$FILE"
  REMOVE_HOST="www.example.com"
  run host_remove
  [[ "$output" == *"Removed www.example.com"* ]]
}

@test "host_remove does not delete a host that is a prefix of another" {
  {
    echo "10.0.0.1 www.example.com"
    echo "10.0.0.2 www.example.com.staging"
  } > "$TOP_LEVEL_FOLDER/$FILE"

  REMOVE_HOST="www.example.com"
  host_remove

  run cat "$TOP_LEVEL_FOLDER/$FILE"
  [[ "$output" != *" www.example.com"$'\n'* ]]
  [[ "$output" == *"www.example.com.staging"* ]]
}
