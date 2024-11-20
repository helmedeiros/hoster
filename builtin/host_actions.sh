#!/usr/bin/env bash
#

function add_host(){
	ADD_HOST="$3";

	define_ip "$2";

	parse_env_arg "$@";
}

function define_ip(){
	ADD_IP="$1";

	if valid_ip "$ADD_IP"; then stat='good'; else stat='bad'; fi
	printf "%-20s: %s\n" "$ADD_IP" "$stat";

	if [ "$stat" == "bad" ]; then die "INVALID IP"; fi
}

function host_add(){
	cmd_set_environment "$ENVIRONMENT";
	echo "$ADD_IP $ADD_HOST" >> "$TOP_LEVEL_FOLDER/$FILE";
}

function remove_host(){
	REMOVE_HOST="$2";
	parse_env_arg "$@";
}

function host_remove(){
	cmd_set_environment "$ENVIRONMENT";
	TARGET="$TOP_LEVEL_FOLDER/$FILE";

	if [ ! -f "$TARGET" ]; then
		echo "No $ENVIRONMENT host file at $TARGET.";
		return 0;
	fi

	pattern="[[:space:]]${REMOVE_HOST}\$|[[:space:]]${REMOVE_HOST}[[:space:]]";

	if ! grep -Eq "$pattern" "$TARGET"; then
		echo "$REMOVE_HOST not found in $ENVIRONMENT.";
		return 0;
	fi

	tmp="$TARGET.tmp";
	grep -Ev "$pattern" "$TARGET" > "$tmp";
	mv "$tmp" "$TARGET";
	echo "Removed $REMOVE_HOST from $ENVIRONMENT.";
}

function list_host(){
	parse_env_arg "$@";
}


function hosts_list(){
	case "$ENVIRONMENT" in
      "all")  for environment in "${environments[@]}"; do
				ACTUAL_ENVIRONMENT="$environment";
				list;
			  done
       ;;
       *) ACTUAL_ENVIRONMENT="$ENVIRONMENT";
			list;
    esac
}

function list(){
	local color
	case "$ACTUAL_ENVIRONMENT" in
		lcl)  color="cyan"    ;;
		dev)  color="green"   ;;
		hlg)  color="yellow"  ;;
		prod) color="red"     ;;
		*)    color="bold"    ;;
	esac
	hoster_color "$color" "################### $ACTUAL_ENVIRONMENT ###################"
	cmd_set_environment "$ACTUAL_ENVIRONMENT";
	run_cmd "cat $TOP_LEVEL_FOLDER/$FILE" "silent";
	printf "\n"
}

function hosts_export(){
	# Emit a JSON document mapping each environment to a list of typed
	# items so order, comments and blank lines all survive the
	# round-trip through import. Format:
	#   {
	#     "project": "<name>",
	#     "environments": {
	#       "lcl": [
	#         {"type": "entry",   "ip": "...", "host": "..."},
	#         {"type": "comment", "value": "# section header"},
	#         {"type": "blank"}
	#       ],
	#       ...
	#     }
	#   }

	# JSON-escape a single value (quotes and backslashes only -- host
	# files cannot legitimately contain control characters).
	_json_escape() {
		local s="$1"
		s="${s//\\/\\\\}"
		s="${s//\"/\\\"}"
		printf '%s' "$s"
	}

	printf '{\n  "project": "%s",\n  "environments": {' "$(_json_escape "$PROJECT_NAME")"

	local first_env=true
	for env in "${environments[@]}"; do
		cmd_set_environment "$env"
		local target="$TOP_LEVEL_FOLDER/$FILE"
		if [ "$first_env" = false ]; then printf ','; fi
		first_env=false
		printf '\n    "%s": [' "$env"

		if [ -s "$target" ]; then
			local first=true
			while IFS= read -r line || [ -n "$line" ]; do
				if [ "$first" = false ]; then printf ','; fi
				first=false

				local trimmed="${line#"${line%%[![:space:]]*}"}"
				if [ -z "$trimmed" ]; then
					printf '\n      {"type": "blank"}'
				elif [[ "$trimmed" == \#* ]]; then
					printf '\n      {"type": "comment", "value": "%s"}' \
						"$(_json_escape "$line")"
				else
					local ip host
					read -r ip host _ <<< "$trimmed"
					printf '\n      {"type": "entry", "ip": "%s", "host": "%s"}' \
						"$(_json_escape "$ip")" "$(_json_escape "$host")"
				fi
			done < "$target"
			printf '\n    '
		fi
		printf ']'
	done

	printf '\n  }\n}\n'
}

function hosts_import(){
	# Read a JSON document produced by hosts_export and overwrite the
	# four environment files with its contents. Requires jq for parsing.

	if [ -z "${IMPORT_FILE:-}" ]; then
		echo "Usage: hoster import <file.json>" >&2
		return 1
	fi

	if [ ! -f "$IMPORT_FILE" ]; then
		echo "Import file not found: $IMPORT_FILE" >&2
		return 1
	fi

	if ! command -v jq >/dev/null; then
		echo "jq is required for import. Install via brew install jq." >&2
		return 1
	fi

	if ! jq -e . "$IMPORT_FILE" >/dev/null 2>&1; then
		echo "Import file is not valid JSON: $IMPORT_FILE" >&2
		return 1
	fi

	if ! jq -e '.environments' "$IMPORT_FILE" >/dev/null 2>&1; then
		echo "Import file missing .environments key: $IMPORT_FILE" >&2
		return 1
	fi

	for env in "${environments[@]}"; do
		cmd_set_environment "$env"
		local target="$TOP_LEVEL_FOLDER/$FILE"
		# Accepts both the typed schema (entry/comment/blank) and the
		# legacy flat schema where each item is an {ip, host} object.
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
		' "$IMPORT_FILE" > "$target"
		hoster_log "Wrote $(wc -l < "$target" | tr -d ' ') lines to $target"
	done

	echo "Imported $IMPORT_FILE into $TOP_LEVEL_FOLDER."
}

function hosts_validate(){
	# Scan every env file for malformed IPs and duplicate hostnames.
	# Returns 0 if every file is clean, 1 if any error was reported.
	# Comments (#...) and blank lines are silently skipped.

	local errors=0
	local warnings=0

	for env in "${environments[@]}"; do
		cmd_set_environment "$env"
		local target="$TOP_LEVEL_FOLDER/$FILE"

		if [ ! -f "$target" ]; then
			continue
		fi

		# Track hostnames within this env to detect duplicates.
		local seen_hosts=""
		local line_no=0

		while IFS= read -r line || [ -n "$line" ]; do
			line_no=$((line_no + 1))
			# Strip leading whitespace.
			local trimmed="${line#"${line%%[![:space:]]*}"}"
			# Skip blank lines and comments.
			if [ -z "$trimmed" ] || [[ "$trimmed" == \#* ]]; then
				continue
			fi

			# Parse "<ip> <host>"; everything past the first two fields is ignored.
			local ip host rest
			read -r ip host rest <<< "$trimmed"

			if [ -z "$ip" ] || [ -z "$host" ]; then
				hoster_color yellow "$env:$line_no: malformed line: $line"
				warnings=$((warnings + 1))
				continue
			fi

			if ! valid_ip "$ip"; then
				hoster_color red "$env:$line_no: invalid IP '$ip' for host '$host'"
				errors=$((errors + 1))
			fi

			if [[ "$seen_hosts" == *"|$host|"* ]]; then
				hoster_color red "$env:$line_no: duplicate host '$host'"
				errors=$((errors + 1))
			else
				seen_hosts="${seen_hosts}|$host|"
			fi
		done < "$target"
	done

	if [ "$errors" -gt 0 ]; then
		hoster_color red "validate: $errors error(s), $warnings warning(s)"
		return 1
	fi

	if [ "$warnings" -gt 0 ]; then
		hoster_color yellow "validate: 0 errors, $warnings warning(s)"
		return 0
	fi

	hoster_color green "validate: all environments are clean"
	return 0
}

function hosts_doctor(){
	# Diagnose the hoster install: bash version, dependency presence,
	# host file resolution, and PATH. Prints a checklist; returns
	# non-zero if a required tool is missing.

	local missing=0

	# $1=ok? (already evaluated), $2=label, $3=hint, $4=severity (req|opt).
	_doctor_report() {
		if [ "$1" = "ok" ]; then
			hoster_color green "  ok  $2"
		elif [ "${4:-req}" = "opt" ]; then
			hoster_color yellow "  --  $2 ($3)"
		else
			hoster_color red   "  !!  $2 ($3)"
			missing=$((missing + 1))
		fi
	}

	hoster_color bold "hoster doctor"

	local host_file
	host_file="$(hoster_os_host_file)"

	echo "Runtime:"
	if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
		_doctor_report ok "bash >= 4"
	else
		_doctor_report fail "bash >= 4" "current: $BASH_VERSION" opt
	fi
	if [ -r "$host_file" ]; then
		_doctor_report ok "host file readable"
	else
		_doctor_report fail "host file readable" "expected: $host_file"
	fi

	echo "Dependencies:"
	for dep in jq shellcheck bats; do
		if command -v "$dep" >/dev/null; then
			_doctor_report ok "$dep"
		else
			case "$dep" in
				jq)         hint="brew install jq"          ;;
				shellcheck) hint="brew install shellcheck"  ;;
				bats)       hint="brew install bats-core"   ;;
			esac
			_doctor_report fail "$dep" "$hint" opt
		fi
	done

	echo "Install:"
	if command -v hoster >/dev/null || command -v hoster.sh >/dev/null; then
		_doctor_report ok "hoster on PATH"
	else
		_doctor_report fail "hoster on PATH" "add the repo dir to PATH"
	fi
	if [ -r "$HOSTER_DIR/hoster.version" ]; then
		_doctor_report ok "hoster.version readable"
	else
		_doctor_report fail "hoster.version readable" "expected at: $HOSTER_DIR/hoster.version"
	fi

	# Project-level diagnostics are best-effort: doctor still works
	# outside a project (TOP_LEVEL_FOLDER unset), so each check is
	# guarded.
	if [ -n "${TOP_LEVEL_FOLDER:-}" ] && [ -d "$TOP_LEVEL_FOLDER" ]; then
		echo "Project:"
		if [ -f "$TOP_LEVEL_FOLDER/config" ]; then
			_doctor_report ok ".hosts/config present"
		else
			_doctor_report fail ".hosts/config present" "optional -- name= override missing" opt
		fi
	fi

	echo
	if [ "$missing" -gt 0 ]; then
		hoster_color red "doctor: $missing required check(s) failed"
		return 1
	fi
	hoster_color green "doctor: all required checks passed"
	return 0
}

function hosts_init(){
	FOLDER=$(pwd);
	HOSTS_FOLDER="$FOLDER/$HOST_DEFAULT_FOLDER";

	if [ ! -d "$HOSTS_FOLDER" ]; then
		initialize_hosts "$HOSTS_FOLDER";
	else
		reinitialize_hosts "$HOSTS_FOLDER";
	fi
}

function initialize_hosts(){
	echo "Initialized empty Hosts repository in $HOSTS_FOLDER" >&2
	run_cmd "mkdir $HOSTS_FOLDER" "silent";
	run_cmd "touch $HOSTS_FOLDER/hosts.lcl $HOSTS_FOLDER/hosts.dev $HOSTS_FOLDER/hosts.hml $HOSTS_FOLDER/hosts.prd" "silent";	
}

function reinitialize_hosts(){
	echo "Reinitialized Hosts repository in $HOSTS_FOLDER" >&2
}

function edit_host(){
	parse_env_arg "$@";
}

function hosts_edit(){
	cmd_set_environment "$ENVIRONMENT";
	run_cmd "$DEFAULT_IDE $TOP_LEVEL_FOLDER/$FILE" "silent";
}

function valid_ip(){
    local  ip="$1"
    local  stat=1
    local  octets

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        [[ ${octets[0]} -le 255 && ${octets[1]} -le 255 \
            && ${octets[2]} -le 255 && ${octets[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}