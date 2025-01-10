#!/usr/bin/env bats

load test_helper

setup() {
  # shellcheck source=../core/pure.sh
  source "$PROJECT_ROOT/core/pure.sh"
}

@test "mk_marker_open emits the open template" {
  result="$(mk_marker_open "my-project" "dev")"
  [ "$result" = "##<my-project-dev>##" ]
}

@test "mk_marker_close emits the close template" {
  result="$(mk_marker_close "my-project" "dev")"
  [ "$result" = "##</my-project-dev>##" ]
}

@test "mk_marker handles project names with dashes" {
  result="$(mk_marker_open "hoster-sample" "lcl")"
  [ "$result" = "##<hoster-sample-lcl>##" ]
}

@test "mk_marker handles every standard environment" {
  for env in lcl dev hlg prod; do
    open="$(mk_marker_open  "proj" "$env")"
    close="$(mk_marker_close "proj" "$env")"
    [ "$open"  = "##<proj-$env>##"  ]
    [ "$close" = "##</proj-$env>##" ]
  done
}
