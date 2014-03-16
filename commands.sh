#!/usr/bin/env bash
source $(dirname $0)/version.sh
source $(dirname $0)/help.sh
source $(dirname $0)/builtin/defaults.sh
source $(dirname $0)/builtin/handle_options.sh
source $(dirname $0)/builtin/host_actions.sh
source $(dirname $0)/builtin/host_apply.sh
source $(dirname $0)/builtin/paths.sh



function run_cmd(){
	if [ $# -eq 1 ]; then
    echo "Running: $1";
  fi

  $1;
  
	if [ "$?" -ne "0" ]; then
	  echo "command failed: $1";
	  exit 1;
	fi
}

# Requests add_host inside /builtin/host_actions.sh
function cmd_add_host(){
  add_host $@;
}

# Requests host_add inside /builtin/host_actions.sh
function cmd_host_add(){
  host_add;
}

# Requests list_host inside /builtin/host_actions.sh
function cmd_list_host(){
  list_host $@;
}

# Requests hosts_list inside /builtin/host_actions.sh
function cmd_hosts_list(){
  hosts_list;
}

# Requests hosts_apply inside /builtin/host_apply.sh
function cmd_hosts_apply(){
  hosts_apply;
}

# Requests apply_host inside /builtin/host_apply.sh
function cmd_apply_host(){ 
	apply_host $@; 
}

# Requests append_host inside /builtin/host_apply.sh
function cmd_append_hosts(){
  append_host $@;
}

# Requests cmd_edit_host inside /builtin/host_actions.sh
function cmd_edit_host(){
  edit_host $@;
}

# Requests cmd_hosts_edit inside /builtin/host_actions.sh
function cmd_hosts_edit(){
	hosts_edit;
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

# Requests version inside version.sh
function cmd_show_version(){
  version;
} 

function cmd_close_when_no_parameters(){
	if [ -z "$1" ]; then
        break;
      fi
}

function cmd_execute_options(){
  case "$COMMAND" in
    ADD)
      cmd_host_add;
    ;;
    APPLY)
      cmd_hosts_apply;
    ;;
    EDIT)
      cmd_hosts_edit;
    ;;
    HELP)
      cmd_list_help_commands;
    ;;
    INIT)
      cmd_hosts_init;
    ;;
    LIST)
      cmd_hosts_list;
    ;;
    VERSION)
      cmd_show_version;
    ;;
  esac
}

function cmd_set_environment(){
	case "$1" in

        # Set development's host file
        dev)
          FILE="hosts.dev";
        ;;

        # Set homolagtion's host file
        hlg)
          FILE="hosts.hml";
        ;;

        # Set localhost's host file
        lcl)
          FILE="hosts.lcl";
        ;;

        # Set production's host file
        prod)  
          FILE="hosts.prd";
        ;;

      esac
}

function cmd_top_level(){
  found=$(find \. -type d -name "$HOST_DEFAULT_FOLDER");

  if [ -n "$found" ]; then
    run_cmd "cd $HOST_DEFAULT_FOLDER" "silent";
    TOP_LEVEL_FOLDER=$(pwd);
  else
    run_cmd "cd .." "silent";
    cmd_top_level;
  fi
}

function cmd_project_name(){
  PROJECT_NAME="${TOP_LEVEL_FOLDER%/*}";
  PROJECT_NAME="${PROJECT_NAME##/*/}";
}

# Custom die function.
function die() { echo >&2 -e "\nERROR: $@\n"; exit 1; }