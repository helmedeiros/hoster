#!/usr/bin/env bash
#
# core/pure.sh -- pure functions for hoster.
#
# Nothing in this file touches sudo, the filesystem, the clock, or
# the terminal. Inputs come from arguments; outputs go to stdout or
# the exit status. Test it directly; do not stub anything.

# json_escape emits its argument with the two characters JSON cares
# about ("\\" and "\"") backslash-escaped. Host file content is plain
# ASCII in practice, so escaping control characters is left out by
# design -- the helper exists so the export path produces valid JSON,
# not to round-trip arbitrary binary.
function json_escape(){
	local s="$1"
	s="${s//\\/\\\\}"
	s="${s//\"/\\\"}"
	printf '%s' "$s"
}

# valid_ip returns 0 if the argument parses as an IPv4 address with
# every octet in [0, 255], non-zero otherwise.
function valid_ip(){
	local ip="$1"
	local stat=1
	local octets

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		IFS='.' read -r -a octets <<< "$ip"
		[[ ${octets[0]} -le 255 && ${octets[1]} -le 255 \
			&& ${octets[2]} -le 255 && ${octets[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}
