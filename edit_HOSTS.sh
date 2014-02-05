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

DEFAULT_IDE="sublime";

ROUTER=$(networksetup -getinfo Ethernet | grep '^Router:' | awk '{print $2}')

echo $ROUTER;

case $ROUTER in
  "172.20.92.1")  FILE_PATH="~/Dropbox/JOBS/RBS/Hosts/";
          echo "CONFIGURING RBS";
          ;;
esac

run_cmd "$DEFAULT_IDE $FILE_PATH$FILE"