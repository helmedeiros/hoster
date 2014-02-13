#!/usr/bin/env bash
#
function handle_options(){
    
  # The user didn't specify a command; give them help
  if [ $# = 0 ]; then
    list_commands;
  else 
    # Execute getopt
    ARGS=$(getopt -o dehHiln:psV -l "dev,edit,hlg,help,init,lcl,net:,prod,set,version" -n "getopt.sh" -- "$@");

    eval set -- "$ARGS";

    # Parse user options
    while true; do
      OPT="$1";
      shift;

      case "$OPT" in

        # Set development's host file
        -d|--dev)
          echo "-choose DEVELOPMENT!" >&2
          FILE="hosts.dev";
        ;;

        # Start editing one environment
        -e|--edit)
          set_path;
          run_cmd "$DEFAULT_IDE $FILE_PATH$FILE";
        ;;

        # Set homolagtion's host file
        -h|--hlg)
          echo "-choose HOMOLOGATION!" >&2
          FILE="hosts.hml";
        ;;

        # Set homolagtion's host file
        -H|--help)
          list_commands;
          exit 1;
        ;;

        # create environment hosts
        -i|--init)            
          cmd_hosts_init; 
          exit 1;
        ;;

        # Set localhost's host file
        -l|--lcl)
          echo "-choose LOCAL!" >&2
          FILE="hosts.lch";
        ;;

        -n|--net)
          shift;
          if [ -n "$1" ]; then    
            network=${OPTARG}   
            ROUTER=$(networksetup -getinfo $network | grep '^Router:' | awk '{print $2}')
          else
            die "Invalid parameter for network: ${OPTARG}."
          fi
        ;;

        # Set production's host file
        -p|--prod)  
          echo "-choose PRODUCTION!" >&2
          FILE="hosts.prd";
        ;;

        # Set one environment
        -s|--set)
          HOST_PATH="/private/etc";
          set_path;
          run_cmd "sudo mv $HOST_PATH/Hosts $HOST_PATH/tmp"
          run_cmd "sudo cp $FILE_PATH$FILE $HOST_PATH/Hosts"
        ;;  

        # Show the version
        -V|--version)
          version;
          exit 1;
        ;;  

        \?)        
          die "Invalid option: -$OPTARG"
        ;;
          
        :)
          die "Option -$OPTARG requires an argument."
        ;;
      esac
    done
  fi
}