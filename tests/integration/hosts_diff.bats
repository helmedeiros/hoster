#!/usr/bin/env bats

load ../test_helper

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
  sudo() { "$@"; }
  export -f sudo
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_diff exits 0 when project env file missing" {
  run hosts_diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"No dev host file"* ]]
}

@test "hosts_diff shows would-add when nothing is applied" {
  cat > "$TMPDIR_TEST/hosts.dev" <<EOF
10.0.0.1 dev.example.com
EOF
  run hosts_diff
  [[ "$output" == *"Nothing applied"* ]]
  [[ "$output" == *"dev.example.com"* ]]
}

@test "hosts_diff reports no diff when applied matches project" {
  cat > "$TMPDIR_TEST/hosts.dev" <<EOF
10.0.0.1 dev.example.com
EOF
  cat > "$HOST_FILE" <<EOF
##<bats-project-dev>##
10.0.0.1 dev.example.com
##</bats-project-dev>##
EOF

  run hosts_diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"Diff between applied"* ]]
}

@test "hosts_diff highlights an out-of-sync entry" {
  cat > "$TMPDIR_TEST/hosts.dev" <<EOF
10.0.0.2 dev.example.com
EOF
  cat > "$HOST_FILE" <<EOF
##<bats-project-dev>##
10.0.0.1 dev.example.com
##</bats-project-dev>##
EOF

  run hosts_diff
  [[ "$output" == *"10.0.0.1"* ]]
  [[ "$output" == *"10.0.0.2"* ]]
}

@test "hosts_diff cleans up its temp file" {
  cat > "$TMPDIR_TEST/hosts.dev" <<EOF
10.0.0.1 dev.example.com
EOF
  hosts_diff
  [ ! -f "$TOP_LEVEL_FOLDER/Hosts.diff.tmp" ]
}
