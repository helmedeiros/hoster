#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  PROJECT_NAME="bats-project"
  ENVIRONMENT="dev"
  HOST_FILE="$TMPDIR_TEST/etc-hosts"
  : > "$HOST_FILE"
  PROJECT_HOSTS="$TMPDIR_TEST/project-hosts.dev"
  cat > "$PROJECT_HOSTS" <<EOF
10.0.0.1 dev.example.com
10.0.0.2 api.dev.example.com
EOF
  # Stub sudo to passthrough so writes happen as the test user.
  sudo() { "$@"; }
  export -f sudo
  cd "$TMPDIR_TEST"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "append_host writes the open and close markers" {
  append_host "$PROJECT_HOSTS"

  run cat "$HOST_FILE"
  [[ "$output" == *"##<bats-project-dev>##"* ]]
  [[ "$output" == *"##</bats-project-dev>##"* ]]
}

@test "append_host writes the project host entries verbatim" {
  append_host "$PROJECT_HOSTS"

  run cat "$HOST_FILE"
  [[ "$output" == *"10.0.0.1 dev.example.com"* ]]
  [[ "$output" == *"10.0.0.2 api.dev.example.com"* ]]
}

@test "append_host preserves existing host file content" {
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  append_host "$PROJECT_HOSTS"

  run cat "$HOST_FILE"
  [[ "$output" == *"127.0.0.1 localhost"* ]]
}

@test "append_host cleans up the temp file" {
  append_host "$PROJECT_HOSTS"
  [ ! -f "$TOP_LEVEL_FOLDER/$APPLY_TMP_NAME" ]
}

@test "append_host replaces an existing block instead of duplicating" {
  # First apply.
  append_host "$PROJECT_HOSTS"

  # Mutate the source and re-apply.
  cat > "$PROJECT_HOSTS" <<EOF
10.0.0.99 newly-added.dev.example.com
EOF
  append_host "$PROJECT_HOSTS"

  # Only one open/close marker pair should remain.
  opens=$(grep -c "##<bats-project-dev>##" "$HOST_FILE")
  closes=$(grep -c "##</bats-project-dev>##" "$HOST_FILE")
  [ "$opens" = "1" ]
  [ "$closes" = "1" ]

  # New entry present, old removed.
  run cat "$HOST_FILE"
  [[ "$output" == *"newly-added.dev.example.com"* ]]
  [[ "$output" != *"api.dev.example.com"* ]]
}

@test "append_host writes a backup of the system hosts file" {
  echo "127.0.0.1 localhost" > "$HOST_FILE"
  before="$(cat "$HOST_FILE")"

  append_host "$PROJECT_HOSTS"

  # One backup file under .hosts/backup/ named *-apply-dev.hosts
  shopt -s nullglob
  backups=( "$TOP_LEVEL_FOLDER/$HOST_BACKUP_DIR"/*-apply-dev.hosts )
  shopt -u nullglob
  [ "${#backups[@]}" -ge 1 ]

  # Backup contains the pre-apply state.
  run cat "${backups[0]}"
  [[ "$output" == *"127.0.0.1 localhost"* ]]
  [[ "$output" != *"##<bats-project-dev>##"* ]]
}

@test "append_host does not touch other-project blocks" {
  {
    echo "##<other-project-dev>##"
    echo "10.0.0.50 theirs.local"
    echo "##</other-project-dev>##"
  } > "$HOST_FILE"

  append_host "$PROJECT_HOSTS"

  run cat "$HOST_FILE"
  [[ "$output" == *"other-project-dev"* ]]
  [[ "$output" == *"theirs.local"* ]]
}
