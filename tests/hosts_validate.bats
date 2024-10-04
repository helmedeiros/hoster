#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_validate returns 0 on empty project" {
  run hosts_validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"all environments are clean"* ]]
}

@test "hosts_validate accepts well-formed entries" {
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"
  echo "127.0.0.1 lcl.example.com" > "$TMPDIR_TEST/hosts.lcl"

  run hosts_validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"clean"* ]]
}

@test "hosts_validate ignores blank lines and comments" {
  cat > "$TMPDIR_TEST/hosts.dev" <<'EOF'
# project hosts
10.0.0.1 dev.example.com

# api
10.0.0.2 api.dev.example.com
EOF

  run hosts_validate
  [ "$status" -eq 0 ]
}

@test "hosts_validate reports an invalid IP" {
  echo "256.0.0.1 bad.example.com" > "$TMPDIR_TEST/hosts.dev"

  run hosts_validate
  [ "$status" -eq 1 ]
  [[ "$output" == *"invalid IP '256.0.0.1'"* ]]
}

@test "hosts_validate reports duplicate hosts within an env" {
  {
    echo "10.0.0.1 dup.example.com"
    echo "10.0.0.2 dup.example.com"
  } > "$TMPDIR_TEST/hosts.dev"

  run hosts_validate
  [ "$status" -eq 1 ]
  [[ "$output" == *"duplicate host 'dup.example.com'"* ]]
}

@test "hosts_validate allows same host across different envs" {
  echo "10.0.0.1 svc.example.com" > "$TMPDIR_TEST/hosts.dev"
  echo "10.1.0.1 svc.example.com" > "$TMPDIR_TEST/hosts.hml"

  run hosts_validate
  [ "$status" -eq 0 ]
}

@test "hosts_validate warns on malformed line but exits 0" {
  echo "missingsecondfield" > "$TMPDIR_TEST/hosts.dev"

  run hosts_validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"malformed line"* ]]
}

@test "hosts_validate reports line numbers and env in errors" {
  {
    echo "10.0.0.1 first.example.com"
    echo "999.0.0.1 second.example.com"
  } > "$TMPDIR_TEST/hosts.dev"

  run hosts_validate
  [[ "$output" == *"dev:2"* ]]
}

@test "hosts_validate exits 1 with mixed errors and warnings" {
  {
    echo "256.0.0.1 bad.example.com"
    echo "missingsecond"
  } > "$TMPDIR_TEST/hosts.dev"

  run hosts_validate
  [ "$status" -eq 1 ]
  [[ "$output" == *"error(s)"* ]]
  [[ "$output" == *"warning(s)"* ]]
}
