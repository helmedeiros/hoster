#!/usr/bin/env bash
#

environments=(lcl dev hlg prod);

function add_host(){
	ADD_IP="$2";
	ADD_HOST="$3";

	handle_env_options $4;
}

function host_add(){
	cmd_set_environment $ENVIRONMENT;
	echo "$ADD_IP $ADD_HOST" >> "$TOP_LEVEL_FOLDER/$FILE";
}

function list_host(){
	handle_env_options $2;	
}


function hosts_list(){
	case $ENVIRONMENT in
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
	printf 	"################### $ACTUAL_ENVIRONMENT ################### \n";
	cmd_set_environment $ACTUAL_ENVIRONMENT;
	run_cmd "cat $TOP_LEVEL_FOLDER/$FILE" "silent";
	printf "\n"
}

function hosts_init(){
	FOLDER=$(pwd);
	HOSTS_FOLDER="$FOLDER/$HOST_DEFAULT_FOLDER";

	echo "Initialized empty Hosts repository in $HOSTS_FOLDER" >&2
	run_cmd "mkdir $HOSTS_FOLDER" "silent";
	run_cmd "touch $HOSTS_FOLDER/hosts.lcl $HOSTS_FOLDER/hosts.dev $HOSTS_FOLDER/hosts.hml $HOSTS_FOLDER/hosts.prd" "silent";	
}

function edit_host(){
	handle_env_options $2;
}

function hosts_edit(){
	cmd_set_environment $ENVIRONMENT;
	run_cmd "$DEFAULT_IDE $TOP_LEVEL_FOLDER/$FILE" "silent";
}