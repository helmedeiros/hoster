#!/usr/bin/env bash
#
# release.sh - cut a new hoster release.
#
# Usage:
#   scripts/release.sh [--dry-run] <version>
#
# Performs:
#   1. Updates hoster.version
#   2. Updates the <version> in pom.xml
#   3. Commits, tags v<version>
#
# With --dry-run, prints the actions but writes no files and creates
# no commit / tag. Does not push or invoke maven either way; that
# stays under operator control.

set -euo pipefail

DRY_RUN=false
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=true; shift ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

if [ $# -ne 1 ]; then
  echo "Usage: $0 [--dry-run] <version>" >&2
  exit 1
fi

VERSION="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say() {
  if [ "$DRY_RUN" = "true" ]; then
    echo "[dry-run] $*"
  fi
}

# Reject obviously wrong version strings early.
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.+-]+)?$ ]]; then
  echo "Invalid version: '$VERSION' (expected X.Y.Z or X.Y.Z-LABEL)" >&2
  exit 1
fi

# Skip dirty / tag-exists checks under dry-run; the point of a dry-run
# is to inspect what would happen from any state, including mid-edit.
if [ "$DRY_RUN" != "true" ]; then
  if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
    echo "Working tree has uncommitted changes. Commit or stash first." >&2
    exit 1
  fi

  if git -C "$ROOT" rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "Tag v$VERSION already exists." >&2
    exit 1
  fi
fi

if [ "$DRY_RUN" = "true" ]; then
  say "would write '$VERSION' to hoster.version"
  say "would rewrite project <version> in pom.xml"
  say "would commit: \"Release $VERSION\""
  say "would tag: v$VERSION"
  exit 0
fi

echo "$VERSION" > "$ROOT/hoster.version"

# Update <version>X</version> inside the top-level <project> block.
# Restrict to the first occurrence so plugin versions are untouched.
awk -v v="$VERSION" '
  !done && /<artifactId>hoster<\/artifactId>/ { print; in_proj=1; next }
  in_proj && /<version>.*<\/version>/ {
    sub(/<version>[^<]*<\/version>/, "<version>" v "</version>")
    in_proj=0; done=1
  }
  { print }
' "$ROOT/pom.xml" > "$ROOT/pom.xml.tmp"
mv "$ROOT/pom.xml.tmp" "$ROOT/pom.xml"

git -C "$ROOT" add hoster.version pom.xml
git -C "$ROOT" commit -m "Release $VERSION"
git -C "$ROOT" tag "v$VERSION"

echo "Tagged v$VERSION. Push with: git push origin master --tags"
