#!/usr/bin/env bats

load ../test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  echo "127.0.0.1 localhost" > "$HOST_FILE"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hoster_backup creates the backup directory" {
  hoster_backup "test" > /dev/null
  [ -d "$TMPDIR_TEST/$HOST_BACKUP_DIR" ]
}

@test "hoster_backup writes a file named with timestamp and reason" {
  dest="$(hoster_backup "apply")"
  [ -f "$dest" ]
  [[ "$dest" == *"-apply.hosts" ]]
}

@test "hoster_backup file matches HOST_FILE byte-for-byte" {
  dest="$(hoster_backup "x")"
  diff "$HOST_FILE" "$dest"
}

@test "hoster_backup uses \"mutation\" as default reason" {
  dest="$(hoster_backup)"
  [[ "$dest" == *"-mutation.hosts" ]]
}

@test "hoster_backup files sort chronologically when run twice" {
  first="$(hoster_backup "apply")"
  # mtime resolution is whole-seconds; sleep so the second stamp differs.
  sleep 1
  second="$(hoster_backup "clean")"
  [ "$first" != "$second" ]
  [[ "$first" < "$second" ]]
}
