#!/usr/bin/env bash

function apply_host(){
	handle_env_options $2;
}

function hosts_apply(){	
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;	
	run_cmd "sudo cp $TOP_LEVEL_FOLDER/$FILE $HOST_PATH/Hosts"
}

function edit_host(){
	handle_env_options $2;
}

function hosts_edit(){
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;
	run_cmd "$DEFAULT_IDE $TOP_LEVEL_FOLDER/$FILE" "silent";
}