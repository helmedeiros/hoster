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
