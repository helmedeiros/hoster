#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../commands.sh
  source "$PROJECT_ROOT/commands.sh"
  TMPDIR_TEST="$(mktemp -d)"
  PROJECT_DIR="$TMPDIR_TEST/sample-folder/.hosts"
  mkdir -p "$PROJECT_DIR"
  TOP_LEVEL_FOLDER="$PROJECT_DIR"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "cmd_project_name defaults to the parent folder name" {
  cmd_project_name
  [ "$PROJECT_NAME" = "sample-folder" ]
}

@test "cmd_project_name honours name= in .hosts/config" {
  echo "name=custom-project" > "$PROJECT_DIR/config"
  cmd_project_name
  [ "$PROJECT_NAME" = "custom-project" ]
}

@test "cmd_project_name ignores comments and blanks in config" {
  cat > "$PROJECT_DIR/config" <<'EOF'
# project metadata

name=overridden
EOF
  cmd_project_name
  [ "$PROJECT_NAME" = "overridden" ]
}

@test "cmd_project_name strips whitespace around the override value" {
  echo "name=  spaced-out  " > "$PROJECT_DIR/config"
  cmd_project_name
  [ "$PROJECT_NAME" = "spaced-out" ]
}

@test "cmd_project_name falls back to folder name when name= is blank" {
  echo "name=" > "$PROJECT_DIR/config"
  cmd_project_name
  [ "$PROJECT_NAME" = "sample-folder" ]
}

@test "cmd_project_name falls back when config has no name= line" {
  echo "comment-only" > "$PROJECT_DIR/config"
  cmd_project_name
  [ "$PROJECT_NAME" = "sample-folder" ]
}
