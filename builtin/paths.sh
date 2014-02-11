#!/usr/bin/env bash
#
function set_path(){
    echo $ROUTER;

    case $ROUTER in
      "172.20.92.1")  FILE_PATH="~/Dropbox/JOBS/RBS/Hosts/";
              echo "CONFIGURING RBS";
              echo "$FILE_PATH";
              ;;
    esac
}