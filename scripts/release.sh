#!/usr/bin/env bash
#
# release.sh - cut a new hoster release.
#
# Usage:
#   scripts/release.sh <version>
#
# Performs:
#   1. Updates hoster.version
#   2. Updates the <version> in pom.xml
#   3. Commits, tags v<version>
#
# Does not push or invoke maven; that stays under operator control.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Reject obviously wrong version strings early.
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.+-]+)?$ ]]; then
  echo "Invalid version: '$VERSION' (expected X.Y.Z or X.Y.Z-LABEL)" >&2
  exit 1
fi

# Refuse to release with uncommitted changes -- the commit at the end
# would otherwise pick up unrelated work.
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  echo "Working tree has uncommitted changes. Commit or stash first." >&2
  exit 1
fi

# Refuse to release if the tag already exists.
if git -C "$ROOT" rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists." >&2
  exit 1
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
