#!/usr/bin/env bash
#
function handle_options(){
    
  # The user didn't specify a command; give them help
  if [ $# = 0 ]; then
    list_commands;
  else 
    # Execute getopt
    ARGS=$(getopt -o ae:HiVdhlp -l "apply,edit:,help,init,version,ev,hlg,lcl,prod" -n "getopt.sh" -- "$@");

    eval set -- "$ARGS";

    # Parse user options
    while true; do
      OPT="$1";
      shift;

      case "$OPT" in

        # Apply one environment
        a|apply)
          cmd_apply_host;
        ;; 

        # Start editing one environment
        e|edit)
          if [ -z "$3" ]; then  
            handle_env_options $3;
            shift;
          else 
            die "Invalid parameter for edit ${1}."
          fi
          set_path ;
          run_cmd "$DEFAULT_IDE $FILE_PATH$FILE";
        ;;

        # Set homolagtion's host file
        --H|--help)
          list_commands;
        ;;

        # create environment hosts
        i|init)            
          cmd_hosts_init;
        ;;

        # Show the version
        --V|--version)
          version;          
        ;;  
      esac

      cmd_close_when_no_parameters $@;
    done
  fi
}

function handle_env_options(){
    echo "ABC-> $2";

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
          echo "-choose DEVELOPMENT!" >&2
          FILE="hosts.dev";
        ;;

        # Set homolagtion's host file
        -h|--hlg)
          echo "-choose HOMOLOGATION!" >&2
          FILE="hosts.hml";
        ;;

        # Set localhost's host file
        -l|--lcl)
          echo "-choose LOCAL!" >&2
          FILE="hosts.lch";
        ;;

        # Set production's host file
        -p|--prod)  
          echo "-choose PRODUCTION!" >&2
          FILE="hosts.prd";
        ;;

      esac
    done
}