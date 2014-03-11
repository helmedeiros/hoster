#!/usr/bin/env bash
#

function add_host(){
	ADD_IP="$2";
	ADD_HOST="$3";

	handle_env_options $4;
}

function host_add(){
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;
	echo "$ADD_IP $ADD_HOST" >> "$TOP_LEVEL_FOLDER/$FILE";
}

function list_host(){
	handle_env_options $2;	
}


function hosts_list(){
	cmd_set_environment $ENVIRONMENT;
	cmd_top_level;
	run_cmd "cat $TOP_LEVEL_FOLDER/$FILE" "silent";
}

function hosts_init(){
	FOLDER=$(pwd);
	HOSTS_FOLDER="$FOLDER/$HOST_DEFAULT_FOLDER";

	echo "Initialized empty Hosts repository in $HOSTS_FOLDER" >&2
	run_cmd "mkdir $HOSTS_FOLDER" "silent";
	run_cmd "touch $HOSTS_FOLDER/hosts.lch $HOSTS_FOLDER/hosts.dev $HOSTS_FOLDER/hosts.hml $HOSTS_FOLDER/hosts.prd" "silent";	
}