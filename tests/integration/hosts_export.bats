#!/usr/bin/env bats

load ../test_helper

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
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_export includes the project name" {
  run hosts_export
  [[ "$output" == *'"project": "bats-project"'* ]]
}

@test "hosts_export emits an environments object with all four keys" {
  run hosts_export
  [[ "$output" == *'"lcl"'* ]]
  [[ "$output" == *'"dev"'* ]]
  [[ "$output" == *'"hlg"'* ]]
  [[ "$output" == *'"prod"'* ]]
}

@test "hosts_export produces empty arrays for empty environments" {
  run hosts_export
  [[ "$output" == *'"lcl": []'* ]]
  [[ "$output" == *'"dev": []'* ]]
}

@test "hosts_export includes ip/host pairs from populated files" {
  echo "10.0.0.1 api.dev.example.com" > "$TMPDIR_TEST/hosts.dev"
  echo "127.0.0.1 lcl.example.com"    > "$TMPDIR_TEST/hosts.lcl"

  run hosts_export
  [[ "$output" == *'"type": "entry"'* ]]
  [[ "$output" == *'"ip": "10.0.0.1"'* ]]
  [[ "$output" == *'"host": "api.dev.example.com"'* ]]
  [[ "$output" == *'"ip": "127.0.0.1"'* ]]
  [[ "$output" == *'"host": "lcl.example.com"'* ]]
}

@test "hosts_export produces valid JSON parseable by jq" {
  echo "10.0.0.1 api.dev.example.com" > "$TMPDIR_TEST/hosts.dev"

  if ! command -v jq >/dev/null; then
    skip "jq not installed"
  fi

  hosts_export > "$TMPDIR_TEST/out.json"
  run jq -e '.environments.dev[0].type == "entry" and .environments.dev[0].ip == "10.0.0.1"' "$TMPDIR_TEST/out.json"
  [ "$status" -eq 0 ]
}

@test "hosts_export escapes quotes and backslashes in values" {
  printf '10.0.0.1 host"with\\quotes.com\n' > "$TMPDIR_TEST/hosts.dev"

  run hosts_export
  [[ "$output" == *'host\"with\\quotes.com'* ]]
}

@test "hosts_export tags comment lines as type=comment" {
  echo "# section header" > "$TMPDIR_TEST/hosts.dev"

  run hosts_export
  [[ "$output" == *'"type": "comment"'* ]]
  [[ "$output" == *'"value": "# section header"'* ]]
  [[ "$output" != *'"ip": "#"'* ]]
}

@test "hosts_export tags blank lines as type=blank" {
  printf '10.0.0.1 dev.example.com\n\n10.0.0.2 api.dev.example.com\n' > "$TMPDIR_TEST/hosts.dev"

  run hosts_export
  [[ "$output" == *'"type": "blank"'* ]]
}

@test "hosts_export preserves order of comments, blanks and entries" {
  if ! command -v jq >/dev/null; then
    skip "jq not installed"
  fi
  cat > "$TMPDIR_TEST/hosts.dev" <<'EOF'
# api hosts
10.0.0.1 api.dev.example.com

# auth
10.0.0.2 auth.dev.example.com
EOF

  hosts_export > "$TMPDIR_TEST/out.json"
  types=$(jq -r '.environments.dev | map(.type) | join(",")' "$TMPDIR_TEST/out.json")
  [ "$types" = "comment,entry,blank,comment,entry" ]
}
