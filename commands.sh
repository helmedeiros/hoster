#!/usr/bin/env bash
HOSTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HOSTER_DIR/version.sh"
source "$HOSTER_DIR/help.sh"
source "$HOSTER_DIR/builtin/os.sh"
source "$HOSTER_DIR/builtin/defaults.sh"
source "$HOSTER_DIR/builtin/handle_options.sh"
source "$HOSTER_DIR/builtin/host_actions.sh"
source "$HOSTER_DIR/builtin/host_apply.sh"
source "$HOSTER_DIR/builtin/paths.sh"



function hoster_log(){
	if [ "${VERBOSE:-false}" = "true" ]; then
		echo "$@" >&2;
	fi
}

function run_cmd(){
	if [ $# -eq 1 ]; then
		hoster_log "Running: $1";
	fi

	if ! $1; then
		echo "command failed: $1";
		exit 1;
	fi
}

# Requests add_host inside /builtin/host_actions.sh
function cmd_add_host(){
  add_host "$@";
}

# Requests host_add inside /builtin/host_actions.sh
function cmd_host_add(){
  host_add;
}

# Requests remove_host inside /builtin/host_actions.sh
function cmd_remove_host(){
  remove_host "$@";
}

# Requests host_remove inside /builtin/host_actions.sh
function cmd_host_remove(){
  host_remove;
}

# Requests list_host inside /builtin/host_actions.sh
function cmd_list_host(){
  list_host "$@";
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
	apply_host "$@";
}

# Requests clean_host inside /builtin/host_apply.sh
function cmd_clean_host(){
	clean_host "$@";
}

# Requests hosts_clean inside /builtin/host_apply.sh
function cmd_hosts_clean(){
	hosts_clean;
}

# Requests append_host inside /builtin/host_apply.sh
function cmd_append_hosts(){
  append_host "$@";
}

# Requests cmd_edit_host inside /builtin/host_actions.sh
function cmd_edit_host(){
  edit_host "$@";
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
	define_defaults "$@";
} 

# Requests handle_options inside /builtin/handle_options.sh
function cmd_handle_options(){
	handle_options "$@";
} 

function cmd_list_help_commands(){
	list_common_cmds_help;
}

# Requests version inside version.sh
function cmd_show_version(){
  version;
} 

function cmd_execute_options(){
  case "$COMMAND" in
    ADD)
      cmd_host_add;
    ;;
    REMOVE)
      cmd_host_remove;
    ;;
    APPLY)
      cmd_hosts_apply;
    ;;
    CLEAN)
      cmd_hosts_clean;
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