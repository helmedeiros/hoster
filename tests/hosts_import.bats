#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  PROJECT_NAME="bats-project"
  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"

  if ! command -v jq >/dev/null; then
    skip "jq not installed"
  fi
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_import errors when no file path is given" {
  unset IMPORT_FILE
  run hosts_import
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "hosts_import errors when file does not exist" {
  IMPORT_FILE="$TMPDIR_TEST/does-not-exist.json"
  run hosts_import
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "hosts_import errors on malformed JSON" {
  IMPORT_FILE="$TMPDIR_TEST/bad.json"
  echo "{ not valid" > "$IMPORT_FILE"
  run hosts_import
  [ "$status" -ne 0 ]
  [[ "$output" == *"not valid JSON"* ]]
}

@test "hosts_import errors when .environments is missing" {
  IMPORT_FILE="$TMPDIR_TEST/no-envs.json"
  echo '{"project": "x"}' > "$IMPORT_FILE"
  run hosts_import
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing .environments"* ]]
}

@test "hosts_import writes entries into the env files" {
  IMPORT_FILE="$TMPDIR_TEST/in.json"
  cat > "$IMPORT_FILE" <<'EOF'
{
  "project": "bats-project",
  "environments": {
    "lcl": [{"ip": "127.0.0.1", "host": "lcl.example.com"}],
    "dev": [{"ip": "10.0.0.1", "host": "dev.example.com"}],
    "hlg": [],
    "prod": []
  }
}
EOF

  hosts_import

  run cat "$TMPDIR_TEST/hosts.lcl"
  [[ "$output" == "127.0.0.1 lcl.example.com" ]]
  run cat "$TMPDIR_TEST/hosts.dev"
  [[ "$output" == "10.0.0.1 dev.example.com" ]]
}

@test "hosts_import truncates empty environments to empty files" {
  echo "10.0.0.99 stale.example.com" > "$TMPDIR_TEST/hosts.dev"
  IMPORT_FILE="$TMPDIR_TEST/in.json"
  cat > "$IMPORT_FILE" <<'EOF'
{
  "environments": {
    "lcl": [],
    "dev": [],
    "hlg": [],
    "prod": []
  }
}
EOF

  hosts_import

  [ ! -s "$TMPDIR_TEST/hosts.dev" ]
}

@test "hosts_import confirms with a final message" {
  IMPORT_FILE="$TMPDIR_TEST/in.json"
  echo '{"environments":{"lcl":[],"dev":[],"hlg":[],"prod":[]}}' > "$IMPORT_FILE"

  run hosts_import
  [[ "$output" == *"Imported"* ]]
}
