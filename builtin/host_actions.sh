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
	# Emit a JSON document mapping each environment to its host entries.
	# Format:
	#   {
	#     "project": "<name>",
	#     "environments": {
	#       "lcl": [{"ip":"...","host":"..."}, ...],
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
			while IFS=$' \t' read -r ip host _; do
				[ -z "$ip" ] && continue
				if [ "$first" = false ]; then printf ','; fi
				first=false
				printf '\n      {"ip": "%s", "host": "%s"}' \
					"$(_json_escape "$ip")" "$(_json_escape "$host")"
			done < "$target"
			printf '\n    '
		fi
		printf ']'
	done

	printf '\n  }\n}\n'
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
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}