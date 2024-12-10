#!/usr/bin/env bash
#
function handle_options(){
    
  # The user didn't specify a command; give them help
  if [ $# = 0 ]; then
    list_commands;
  else 
    handle_main_options "$@";
  fi
}


function handle_main_options(){
  COMMAND="";
  VERBOSE="${VERBOSE:-false}";
  FORCE="${FORCE:-false}";

   # Parse user options
   while [ $# -gt 0 ]; do
      OPT=$1;

      case "$OPT" in

        # Verbose mode -- consumed in place, loop continues.
        --verbose|-v)
          VERBOSE="true";
          shift;
          continue;
        ;;

        # Force destructive operations (apply --prod). Consumed in place.
        --force|-f)
          FORCE="true";
          shift;
          continue;
        ;;

        # Apply one environment
        apply)
          COMMAND="APPLY";
          cmd_top_level;
          cmd_project_name;
          cmd_apply_host "$@";
          break;
        ;;

        # Clean one environment from the system hosts file
        clean)
          COMMAND="CLEAN";
          cmd_top_level;
          cmd_project_name;
          cmd_clean_host "$@";
          break;
        ;;

        # Add a host to the project
        add)
          COMMAND="ADD";
          cmd_top_level;
          cmd_project_name;
          cmd_add_host "$@";
          break;
        ;;

        # Remove a host from the project
        remove|rm)
          COMMAND="REMOVE";
          cmd_top_level;
          cmd_project_name;
          cmd_remove_host "$@";
          break;
        ;;

        # Start editing one environment
        edit)
          COMMAND="EDIT";
          cmd_top_level;
          cmd_project_name;
          cmd_edit_host "$@";
          break;
        ;;

        # Set homolagtion's host file
        --H|--help)
          COMMAND="HELP";
          break;
        ;;

        # create environment hosts
        i|init)            
          COMMAND="INIT";
          break;
        ;;

        list)
          COMMAND="LIST";
          cmd_top_level;
          cmd_project_name;
          cmd_list_host "$@";
          break;
        ;;

        # Show which environment, if any, is currently applied.
        status)
          COMMAND="STATUS";
          cmd_top_level;
          cmd_project_name;
          break;
        ;;

        # Preview what apply would change
        diff)
          COMMAND="DIFF";
          cmd_top_level;
          cmd_project_name;
          cmd_diff_host "$@";
          break;
        ;;

        # Dump all environments as JSON
        export)
          COMMAND="EXPORT";
          cmd_top_level;
          cmd_project_name;
          break;
        ;;

        # Load environments from a JSON file produced by export
        import)
          COMMAND="IMPORT";
          cmd_top_level;
          cmd_project_name;
          IMPORT_FILE="$2";
          break;
        ;;

        # Sanity-check the project's env files
        validate)
          COMMAND="VALIDATE";
          cmd_top_level;
          cmd_project_name;
          break;
        ;;

        # Diagnose the hoster environment (deps, paths, perms)
        doctor)
          COMMAND="DOCTOR";
          break;
        ;;

        # List or restore atomic backups
        history)
          COMMAND="HISTORY";
          cmd_top_level;
          cmd_project_name;
          HISTORY_ACTION="$2";
          HISTORY_TARGET="$3";
          break;
        ;;

        # Print URLs for an environment's hosts (useful for scripts).
        open)
          COMMAND="OPEN";
          cmd_top_level;
          cmd_project_name;
          cmd_open_host "$@";
          break;
        ;;

        # Show the version
        --V|--version)
          COMMAND="VERSION";
          break;
        ;;

        *)
          echo "$progname: '$OPT' is not a $progname command. See '$progname --help'."  
          break;        
        ;; 
      esac
    done
}

function handle_env_options(){
    # Scan the forwarded arguments for an environment flag. GNU getopt
    # and BSD getopt (macOS) disagree about long-option support, so
    # walk the args by hand to stay portable.
    ENVIRONMENT="all";

    local arg
    for arg in "$@"; do
      case "$arg" in
        -d|--dev)  ENVIRONMENT="dev";  return ;;
        -h|--hlg)  ENVIRONMENT="hlg";  return ;;
        -l|--lcl)  ENVIRONMENT="lcl";  return ;;
        -p|--prod) ENVIRONMENT="prod"; return ;;
      esac
    done
}