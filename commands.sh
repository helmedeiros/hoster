#!/usr/bin/env bash
source $(dirname $0)/help.sh
source $(dirname $0)/version.sh
source $(dirname $0)/builtin/defaults.sh
source $(dirname $0)/builtin/handle_options.sh
source $(dirname $0)/builtin/host_actions.sh
source $(dirname $0)/builtin/paths.sh



function run_cmd(){
	echo "Running: $1";
	$1;

	if [ "$?" -ne "0" ]; then
	  echo "command failed: $1"
	  exit 1
	fi
}

# Requests hosts_init inside /builtin/host_actions.sh
function cmd_hosts_init(){ 
	hosts_init; 
}

# Requests define_defaults inside /builtin/defaults.sh
function cmd_define_defaults(){
	define_defaults $@;
} 

# Requests handle_options inside /builtin/handle_options.sh
function cmd_handle_options(){
	handle_options $@;
} 

function cmd_list_help_commands(){
	list_common_cmds_help;
}

function cmd_close_when_no_parameters(){
	if [ -z "$1" ]; then
        break;
      fi
}


# Custom die function.
function die() { echo >&2 -e "\nERROR: $@\n"; exit 1; }