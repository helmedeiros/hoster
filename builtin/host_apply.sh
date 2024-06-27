#!/usr/bin/env bash


function apply_host(){
	handle_env_options "$2";
}

function hosts_apply(){
	cmd_set_environment "$ENVIRONMENT";

	HOST_FILE_TO_APPEND="$TOP_LEVEL_FOLDER/$FILE";
	cmd_append_hosts "$HOST_FILE_TO_APPEND";
}

function clean_host(){
	handle_env_options "$2";
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



