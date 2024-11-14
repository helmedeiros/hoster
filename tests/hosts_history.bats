#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  PROJECT_NAME="bats-project"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  sudo() { "$@"; }
  export -f sudo
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_history reports nothing when no backups exist" {
  unset HISTORY_ACTION HISTORY_TARGET
  run hosts_history
  [ "$status" -eq 0 ]
  [[ "$output" == *"No backups recorded"* ]]
}

@test "hosts_history lists each backup file basename" {
  hoster_backup "apply-dev" > /dev/null
  sleep 1
  hoster_backup "clean-dev" > /dev/null

  unset HISTORY_ACTION
  run hosts_history
  [ "$status" -eq 0 ]
  [[ "$output" == *"-apply-dev.hosts"* ]]
  [[ "$output" == *"-clean-dev.hosts"* ]]
}

@test "hosts_history lists oldest first" {
  hoster_backup "apply-dev" > /dev/null
  sleep 1
  hoster_backup "clean-dev" > /dev/null

  unset HISTORY_ACTION
  run hosts_history
  applied_line=$(echo "$output" | grep -n apply-dev | cut -d: -f1)
  cleaned_line=$(echo "$output" | grep -n clean-dev | cut -d: -f1)
  [ "$applied_line" -lt "$cleaned_line" ]
}

@test "hosts_history restore fails without a target" {
  HISTORY_ACTION="restore"
  unset HISTORY_TARGET
  run hosts_history
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "hosts_history restore fails on missing backup" {
  HISTORY_ACTION="restore"
  HISTORY_TARGET="does-not-exist.hosts"
  run hosts_history
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "hosts_history restore copies backup over HOST_FILE" {
  echo "marker pre-mutation" > "$HOST_FILE"
  backup="$(hoster_backup "apply-dev")"
  echo "marker post-mutation" > "$HOST_FILE"

  HISTORY_ACTION="restore"
  HISTORY_TARGET="$(basename "$backup")"
  run hosts_history
  [ "$status" -eq 0 ]

  run cat "$HOST_FILE"
  [[ "$output" == *"marker pre-mutation"* ]]
  [[ "$output" != *"marker post-mutation"* ]]
}

@test "hosts_history restore creates a pre-restore safety backup" {
  backup="$(hoster_backup "apply-dev")"
  echo "current" > "$HOST_FILE"

  HISTORY_ACTION="restore"
  HISTORY_TARGET="$(basename "$backup")"
  hosts_history

  shopt -s nullglob
  safety=( "$TOP_LEVEL_FOLDER/$HOST_BACKUP_DIR"/*-pre-restore.hosts )
  shopt -u nullglob
  [ "${#safety[@]}" -ge 1 ]
}

@test "hosts_history rejects unknown actions" {
  HISTORY_ACTION="bogus"
  run hosts_history
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown history action"* ]]
}
