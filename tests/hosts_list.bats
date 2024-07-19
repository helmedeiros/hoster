#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
  TMPDIR_TEST="$(mktemp -d)"
  TOP_LEVEL_FOLDER="$TMPDIR_TEST"
  cat > "$TMPDIR_TEST/hosts.dev" <<EOF
10.0.0.1 dev.example.com
EOF
  cat > "$TMPDIR_TEST/hosts.hml" <<EOF
10.1.0.1 hml.example.com
EOF
  cat > "$TMPDIR_TEST/hosts.lcl" <<EOF
127.0.0.1 lcl.example.com
EOF
  cat > "$TMPDIR_TEST/hosts.prd" <<EOF
10.2.0.1 prd.example.com
EOF
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "hosts_list dev prints only the dev entries" {
  ENVIRONMENT="dev"
  run hosts_list
  [[ "$output" == *"dev.example.com"* ]]
  [[ "$output" != *"hml.example.com"* ]]
  [[ "$output" != *"lcl.example.com"* ]]
  [[ "$output" != *"prd.example.com"* ]]
}

@test "hosts_list prod prints only the prod entries" {
  ENVIRONMENT="prod"
  run hosts_list
  [[ "$output" == *"prd.example.com"* ]]
  [[ "$output" != *"dev.example.com"* ]]
}

@test "hosts_list all prints every environment" {
  ENVIRONMENT="all"
  run hosts_list
  [[ "$output" == *"dev.example.com"* ]]
  [[ "$output" == *"hml.example.com"* ]]
  [[ "$output" == *"lcl.example.com"* ]]
  [[ "$output" == *"prd.example.com"* ]]
}

@test "hosts_list all prints a banner per environment" {
  ENVIRONMENT="all"
  run hosts_list
  for env in lcl dev hlg prod; do
    [[ "$output" == *"$env"* ]]
  done
}
