#!/usr/bin/env bash
#
function handle_options(){
    
  # The user didn't specify a command; give them help
  if [ $# = 0 ]; then
    list_commands;
  else 
    handle_main_options $@;
  fi
}


function handle_main_options(){
  COMMAND="";  

   # Parse user options
   while [ $# -gt 0 ]; do
      OPT=$1;

      case "$OPT" in

        # Apply one environment
        apply)
          COMMAND="APPLY";
          cmd_apply_host $@;
          break;
        ;; 

        # Add a host to the project
        add)
          COMMAND="ADD";
          cmd_add_host $@;
          break;
        ;; 

        # Start editing one environment
        edit)
          COMMAND="EDIT";
          cmd_edit_host $@;
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
          cmd_list_host $@;
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

      cmd_close_when_no_parameters $@;
    done
}

function handle_env_options(){
    ENVIRONMENT=""; 

    # Execute getopt
    SUBARGS=$(getopt -o dhlp -l "dev,hlg,lcl,prod" -n "getopt.sh" -- "$@");

    eval set -- "$SUBARGS";

    # Parse user options
    while true; do
      SUBOPT="$1";
      shift;

      case "$SUBOPT" in

        # Set development's host file
        -d|--dev)
          ENVIRONMENT="dev";
          break;
        ;;

        # Set homolagtion's host file
        -h|--hlg)
          ENVIRONMENT="hlg";
          break;
        ;;

        # Set localhost's host file
        -l|--lcl)
          ENVIRONMENT="lcl";
          break;
        ;;

        # Set production's host file
        -p|--prod)  
          ENVIRONMENT="prod";
          break;
        ;;

        *)
          ENVIRONMENT="all";
          break;
        ;;
      esac
      cmd_close_when_no_parameters $@;
    done
}