#!/usr/bin/env bash


function apply_host(){
	handle_env_options $2;
}

function hosts_apply(){	
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;	
	
	HOST_FILE_TO_APPEND="$TOP_LEVEL_FOLDER/$FILE";
	cmd_append_hosts $HOST_FILE_TO_APPEND;
}

function append_host(){
	run_cmd "sudo cp $1 $HOST_PATH/Hosts";
}