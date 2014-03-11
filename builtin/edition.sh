#!/usr/bin/env bash
#

function apply_host(){
	HOST_PATH="/private/etc";
	set_path;
	run_cmd "sudo cp $HOST_PATH/Hosts $HOST_PATH/tmp"
	run_cmd "sudo cp $FILE_PATH$FILE $HOST_PATH/Hosts"
}

function edit_host(){
	handle_env_options $2;
}

function hosts_edit(){
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;
	run_cmd "$DEFAULT_IDE $TOP_LEVEL_FOLDER/$FILE" "silent";
}