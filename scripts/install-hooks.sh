#!/usr/bin/env bash
#
# install-hooks.sh - install hoster's git hooks into .git/hooks.
#
# Usage:
#   scripts/install-hooks.sh
#
# Currently provides a pre-commit hook that runs "make all" so a
# broken lint or test cannot be committed.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$ROOT/.git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
	echo "$HOOKS_DIR not found -- run this from the cloned repo." >&2
	exit 1
fi

PRE_COMMIT="$HOOKS_DIR/pre-commit"

cat > "$PRE_COMMIT" <<'EOF'
#!/usr/bin/env bash
#
# hoster pre-commit hook installed by scripts/install-hooks.sh.
# Runs lint + tests before each commit. Bypass with --no-verify
# if you really need to.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if ! command -v shellcheck >/dev/null; then
	echo "shellcheck not found, skipping lint." >&2
else
	echo "Running shellcheck..."
	make lint
fi

if ! command -v bats >/dev/null; then
	echo "bats not found, skipping tests." >&2
else
	echo "Running bats..."
	make test
fi
EOF

chmod +x "$PRE_COMMIT"

echo "Installed pre-commit hook at $PRE_COMMIT"
echo "Bypass with: git commit --no-verify"
