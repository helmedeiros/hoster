#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"
  echo "10.0.0.2 api.dev.example.com" >> "$TMPDIR_TEST/hosts.dev"
  echo "127.0.0.1 lcl.example.com" > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_open --dev prints only dev hosts as https URLs" {
  ENVIRONMENT="dev"
  run hosts_open
  [[ "$output" == *"https://dev.example.com"* ]]
  [[ "$output" == *"https://api.dev.example.com"* ]]
  [[ "$output" != *"https://lcl.example.com"* ]]
}

@test "hosts_open --lcl prints lcl entry" {
  ENVIRONMENT="lcl"
  run hosts_open
  [ "$output" = "https://lcl.example.com" ]
}

@test "hosts_open with ENVIRONMENT=all walks every populated env" {
  ENVIRONMENT="all"
  run hosts_open
  [[ "$output" == *"https://lcl.example.com"* ]]
  [[ "$output" == *"https://dev.example.com"* ]]
}

@test "hosts_open skips empty env files" {
  ENVIRONMENT="all"
  run hosts_open
  count=$(echo "$output" | wc -l | tr -d ' ')
  # 1 lcl + 2 dev = 3 lines; hml and prd are empty.
  [ "$count" = "3" ]
}

@test "hosts_open skips comments and blank lines" {
  cat > "$TMPDIR_TEST/hosts.dev" <<'EOF'
# api section
10.0.0.1 dev.example.com

# auth section
10.0.0.2 api.dev.example.com
EOF
  ENVIRONMENT="dev"
  run hosts_open
  count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$count" = "2" ]
}

@test "hosts_open honours HOSTER_OPEN_SCHEME override" {
  HOSTER_OPEN_SCHEME="http"
  ENVIRONMENT="dev"
  run hosts_open
  [[ "$output" == *"http://dev.example.com"* ]]
  [[ "$output" != *"https://dev.example.com"* ]]
}
