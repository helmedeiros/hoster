#!/usr/bin/env bash
#
# edit_HOST.sh - An host file editor;
#
# Usage:
#
#     # Edit the default host file
#      ./edit_HOST.sh
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      ./edit_HOST.sh -l 
source $(dirname $0)/commands.sh

FILE="Hosts";
FILE_PATH="/private/etc/";
network="Wi-Fi";

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
      if [ -n "$1" ]; then    
        network=${OPTARG}   
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

DEFAULT_IDE="sublime";

echo $ROUTER;

case $ROUTER in
  "172.20.92.1")  FILE_PATH="~/Dropbox/JOBS/RBS/Hosts/";
          echo "CONFIGURING RBS";
          ;;
esac

run_cmd "$DEFAULT_IDE $FILE_PATH$FILE"