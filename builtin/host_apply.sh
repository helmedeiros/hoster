#!/usr/bin/env bash


function apply_host(){
	parse_env_arg "$@";
}

function hosts_apply(){
	if [ "$ENVIRONMENT" = "all" ]; then
		hosts_apply_all
		return
	fi

	cmd_set_environment "$ENVIRONMENT";

	HOST_FILE_TO_APPEND="$TOP_LEVEL_FOLDER/$FILE";
	cmd_append_hosts "$HOST_FILE_TO_APPEND";
}

function hosts_apply_all(){
	local applied=0
	for env in "${environments[@]}"; do
		ENVIRONMENT="$env"
		cmd_set_environment "$env"
		local target="$TOP_LEVEL_FOLDER/$FILE"
		if [ ! -s "$target" ]; then
			hoster_log "Skipping $env (empty)"
			continue
		fi
		hoster_color bold "Applying $env..."
		cmd_append_hosts "$target"
		applied=$((applied + 1))
	done
	echo "Applied $applied environment(s)."
}

function clean_host(){
	parse_env_arg "$@";
}

function diff_host(){
	parse_env_arg "$@";
}

function hosts_diff(){
	cmd_set_environment "$ENVIRONMENT";
	PROJECT_FILE="$TOP_LEVEL_FOLDER/$FILE";

	if [ ! -f "$PROJECT_FILE" ]; then
		hoster_color dim "No $ENVIRONMENT host file at $PROJECT_FILE."
		return 0;
	fi

	APPLIED_TMP="$TOP_LEVEL_FOLDER/Hosts.diff.tmp";
	sudo sed -n "/<$PROJECT_NAME-$ENVIRONMENT>/,/<\/$PROJECT_NAME-$ENVIRONMENT>/{//!p;}" "$HOST_FILE" \
		| tee "$APPLIED_TMP" > /dev/null;

	if [ ! -s "$APPLIED_TMP" ]; then
		hoster_color yellow "Nothing applied for $ENVIRONMENT of $PROJECT_NAME. \"apply\" would add:"
		cat "$PROJECT_FILE";
		rm -f "$APPLIED_TMP";
		return 0;
	fi

	hoster_color bold "Diff between applied $ENVIRONMENT block and $PROJECT_FILE:"
	# Colorize the unified diff: + lines green, - lines red, @@ headers cyan.
	if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
		diff -u "$APPLIED_TMP" "$PROJECT_FILE" \
			| awk '
				/^[+][^+]/ { printf "\033[32m%s\033[0m\n", $0; next }
				/^[-][^-]/ { printf "\033[31m%s\033[0m\n", $0; next }
				/^@@/      { printf "\033[36m%s\033[0m\n", $0; next }
				{ print }
			' || true
	else
		diff -u "$APPLIED_TMP" "$PROJECT_FILE" || true
	fi

	rm -f "$APPLIED_TMP";
}

function hosts_status(){
	if ! grep -Eq "##<$PROJECT_NAME-[a-z]+>##" "$HOST_FILE"; then
		hoster_color dim "No $PROJECT_NAME block applied to $HOST_FILE."
		return 0;
	fi

	applied=$(grep -Eo "##<$PROJECT_NAME-[a-z]+>##" "$HOST_FILE" | sed -E "s/##<$PROJECT_NAME-([a-z]+)>##/\\1/");

	printf '%s applied environments:' "$(hoster_color bold "$PROJECT_NAME")"
	while IFS= read -r env; do
		case "$env" in
			lcl)  printf ' %s' "$(hoster_color cyan    "$env")" ;;
			dev)  printf ' %s' "$(hoster_color green   "$env")" ;;
			hlg)  printf ' %s' "$(hoster_color yellow  "$env")" ;;
			prod) printf ' %s' "$(hoster_color red     "$env")" ;;
			*)    printf ' %s' "$env" ;;
		esac
	done <<< "$applied"
	echo
}

function hosts_clean(){
	cmd_set_environment "$ENVIRONMENT";

	TEMP_APPLY_FILE="$TOP_LEVEL_FOLDER/$APPLY_TMP_NAME";

	find_occurrence;

	if [ "$found" != "true" ]; then
		echo "Nothing to clean for $ENVIRONMENT of $PROJECT_NAME.";
		return 0;
	fi

	remove_occurrence;

	run_cmd "sudo cp $TEMP_APPLY_FILE $HOST_FILE" "silent";
	run_cmd "rm -f $TEMP_APPLY_FILE" "silent";

	echo "Cleaned $ENVIRONMENT of $PROJECT_NAME from $HOST_FILE.";
}

function append_host(){
	TEMP_APPLY_FILE="$TOP_LEVEL_FOLDER/$APPLY_TMP_NAME";

	find_occurrence;

	if [ "$found" == "true" ]; then
		remove_occurrence;
	else
		run_cmd "sudo cp $HOST_FILE $TEMP_APPLY_FILE" "silent";
		run_cmd "sudo chmod 777 $TEMP_APPLY_FILE" "silent";
	fi

	{
		echo "##<$PROJECT_NAME-$ENVIRONMENT>##"
		cat "$1"
		echo "##</$PROJECT_NAME-$ENVIRONMENT>##"
	} >> "$TEMP_APPLY_FILE"

	run_cmd "sudo cp $TEMP_APPLY_FILE $HOST_FILE" "silent";
	run_cmd "rm -f $TEMP_APPLY_FILE" "silent";
}


function find_occurrence(){
	found="false";
	TMP_OCCURRENCE_FILE="$OCCURRENCE_TMP_NAME";

	sudo sed "/<$PROJECT_NAME/,/<\/$PROJECT_NAME/!d" "$HOST_FILE" | tee "$TMP_OCCURRENCE_FILE" > /dev/null;

	if [[ -s "$TMP_OCCURRENCE_FILE" ]] ; then
		echo "HOST for $ENVIRONMENT of project->$PROJECT_NAME found.";
		echo "They are:"
		run_cmd "cat $TMP_OCCURRENCE_FILE" "silent";
		found="true";
	else
		echo "HOST for $ENVIRONMENT of project->$PROJECT_NAME wasn't found.";
	fi

	run_cmd "rm -f $TMP_OCCURRENCE_FILE" "silent";
}

function remove_occurrence(){
	sudo sed "/<$PROJECT_NAME/,/<\/$PROJECT_NAME/d" "$HOST_FILE" | tee "$TEMP_APPLY_FILE" > /dev/null;
}



