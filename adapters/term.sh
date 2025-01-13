#!/usr/bin/env bash
#
# adapters/term.sh -- terminal I/O adapter.
#
# Owns everything that talks to the user's terminal: ANSI coloring
# and the verbose-gated log helper. Tests stub these (or rely on
# the isatty/NO_COLOR gate that makes them no-ops under pipes).

# hoster_color emits an ANSI-wrapped string when stdout is a TTY and
# NO_COLOR is not set; otherwise emits the plain string. Honors the
# https://no-color.org convention.
#
# Usage: hoster_color <name> <text>
# Names: red, green, yellow, blue, magenta, cyan, bold, dim
function hoster_color(){
	local name="$1"; shift
	local text="$*"

	if [ -n "${NO_COLOR-}" ] || [ ! -t 1 ]; then
		echo "$text"
		return
	fi

	local code
	case "$name" in
		red)     code="31" ;;
		green)   code="32" ;;
		yellow)  code="33" ;;
		blue)    code="34" ;;
		magenta) code="35" ;;
		cyan)    code="36" ;;
		bold)    code="1"  ;;
		dim)     code="2"  ;;
		*) echo "$text"; return ;;
	esac

	printf '\033[%sm%s\033[0m\n' "$code" "$text"
}

# hoster_log writes its arguments to stderr when VERBOSE=true, and
# stays silent otherwise. The stderr routing keeps debug output out
# of command substitutions and out of pipelines that downstream
# scripts may consume.
function hoster_log(){
	if [ "${VERBOSE:-false}" = "true" ]; then
		echo "$@" >&2;
	fi
}
