#!/usr/bin/env bash
#
# change_HOST.sh - An host file editor;
#
# Usage:
#
#     # Edit the default host file
#      ./change_HOST.sh
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      ./change_HOST.sh -l 
source $(dirname $0)/commands.sh    

FILE="Hosts";
FILE_PATH="/private/etc/";
network="Wi-Fi";

function handle_options(){
  # Parse user options
  #
  while getopts "ldhpn:" opt; do
    case $opt in

      # Set localhost's host file
      l)
          echo "-choose LOCAL!" >&2
          FILE="hosts.lch";
        ;;

      # Set development's host file
      d)
          echo "-choose DEVELOPMENT!" >&2
          FILE="hosts.dev";
        ;;

      # Set homolagtion's host file
      h)
          echo "-choose HOMOLOGATION!" >&2
          FILE="hosts.hml";
        ;;

      # Set production's host file
      p)
          echo "-choose PRODUCTION!" >&2
          FILE="hosts.prd";
        ;;

      n)
        if [[ "$OPTARG" =~ ^[.*] ; then
          network=${OPTARG}   
          echo "$network";
          ROUTER=$(networksetup -getinfo $network | grep '^Router:' | awk '{print $2}')
        else
          die "Invalid parameter for network: ${OPTARG}."
        fi
        ;;


      \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
      :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    esac
  done
}

function define_path(){
  echo $ROUTER;

  case $ROUTER in
    "172.20.92.1")  FILE_PATH="~/Dropbox/JOBS/RBS/Hosts/";
            echo "CONFIGURING RBS";
          ;;
  esac
}

handle_options $@;
define_path;

run_cmd "mv $FILE_PATH/Hosts $FILE_PATH/tmp"
run_cmd "cp $FILE_PATH$FILE $FILE_PATH/Hosts"