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

@test "export then import reproduces the original entries" {
  {
    echo "127.0.0.1 lcl.example.com"
    echo "127.0.0.2 alt.lcl.example.com"
  } > "$TMPDIR_TEST/hosts.lcl"
  {
    echo "10.0.0.1 dev.example.com"
    echo "10.0.0.2 api.dev.example.com"
  } > "$TMPDIR_TEST/hosts.dev"
  echo "10.1.0.1 hml.example.com" > "$TMPDIR_TEST/hosts.hml"
  echo "10.2.0.1 prd.example.com" > "$TMPDIR_TEST/hosts.prd"

  hosts_export > "$TMPDIR_TEST/dump.json"

  cp "$TMPDIR_TEST/hosts.lcl" "$TMPDIR_TEST/orig.lcl"
  cp "$TMPDIR_TEST/hosts.dev" "$TMPDIR_TEST/orig.dev"
  cp "$TMPDIR_TEST/hosts.hml" "$TMPDIR_TEST/orig.hml"
  cp "$TMPDIR_TEST/hosts.prd" "$TMPDIR_TEST/orig.prd"

  rm "$TMPDIR_TEST"/hosts.{lcl,dev,hml,prd}
  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"

  IMPORT_FILE="$TMPDIR_TEST/dump.json"
  hosts_import

  diff "$TMPDIR_TEST/orig.lcl" "$TMPDIR_TEST/hosts.lcl"
  diff "$TMPDIR_TEST/orig.dev" "$TMPDIR_TEST/hosts.dev"
  diff "$TMPDIR_TEST/orig.hml" "$TMPDIR_TEST/hosts.hml"
  diff "$TMPDIR_TEST/orig.prd" "$TMPDIR_TEST/hosts.prd"
}

@test "export then import is idempotent (no drift on second roundtrip)" {
  echo "10.0.0.1 dev.example.com" > "$TMPDIR_TEST/hosts.dev"

  hosts_export > "$TMPDIR_TEST/dump1.json"
  IMPORT_FILE="$TMPDIR_TEST/dump1.json"
  hosts_import

  hosts_export > "$TMPDIR_TEST/dump2.json"

  diff "$TMPDIR_TEST/dump1.json" "$TMPDIR_TEST/dump2.json"
}

@test "export then import preserves comments and blank lines" {
  cat > "$TMPDIR_TEST/hosts.dev" <<'EOF'
# api hosts
10.0.0.1 api.dev.example.com

# auth
10.0.0.2 auth.dev.example.com
EOF
  cp "$TMPDIR_TEST/hosts.dev" "$TMPDIR_TEST/orig.dev"

  hosts_export > "$TMPDIR_TEST/dump.json"

  : > "$TMPDIR_TEST/hosts.lcl"
  : > "$TMPDIR_TEST/hosts.dev"
  : > "$TMPDIR_TEST/hosts.hml"
  : > "$TMPDIR_TEST/hosts.prd"

  IMPORT_FILE="$TMPDIR_TEST/dump.json"
  hosts_import

  diff "$TMPDIR_TEST/orig.dev" "$TMPDIR_TEST/hosts.dev"
}

@test "hosts_import accepts the legacy flat schema" {
  cat > "$TMPDIR_TEST/legacy.json" <<'EOF'
{
  "project": "bats-project",
  "environments": {
    "lcl": [],
    "dev": [{"ip": "10.0.0.1", "host": "dev.example.com"}],
    "hlg": [],
    "prod": []
  }
}
EOF

  IMPORT_FILE="$TMPDIR_TEST/legacy.json"
  hosts_import

  run cat "$TMPDIR_TEST/hosts.dev"
  [[ "$output" == "10.0.0.1 dev.example.com" ]]
}
