#!/usr/bin/env bash
#
# adapters/json.sh -- JSON reader adapter.
#
# Wraps the jq invocations needed by hosts_import so the import
# code reads as data flow, not as embedded jq programs. Existing
# writers do not need an adapter -- they use core/json_escape and
# hand-roll the output, no dependency on jq.

# json_available exits 0 if jq is on PATH, non-zero otherwise.
function json_available(){
	command -v jq >/dev/null
}

# json_validate exits 0 if the file parses as JSON and contains
# the expected .environments top-level key, non-zero otherwise.
function json_validate(){
	local file="$1"
	jq -e . "$file" >/dev/null 2>&1 || return 1
	jq -e '.environments' "$file" >/dev/null 2>&1 || return 2
	return 0
}

# json_env_to_lines prints one host-file line per item under
# .environments.<env> in the named JSON file. Comment items emit
# their preserved value, blank items emit empty lines, entry items
# emit "<ip> <host>". Legacy items (no type field) are treated as
# entries too. The output is the exact content the import path
# should write into hosts.<env>.
function json_env_to_lines(){
	local file="$1"
	local env="$2"
	jq -r --arg env "$env" '
		.environments[$env] // []
		| map(
			if .type == "comment" then .value
			elif .type == "blank"   then ""
			elif .type == "entry"   then "\(.ip) \(.host)"
			else "\(.ip) \(.host)"
			end
		)
		| .[]
	' "$file"
}
