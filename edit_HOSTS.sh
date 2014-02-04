#!/usr/bin/env bash

source $(dirname $0)/commands.sh

DEFAULT_IDE="sublime";
FILE="hosts.lch";

ROUTER=$(networksetup -getinfo Ethernet | grep '^Router:' | awk '{print $2}')

echo $ROUTER;

case $ROUTER in
	"172.20.92.1") 	FILE_PATH="~/Dropbox/JOBS/RBS/Hosts/";
					echo "CONFIGURING RBS";
esac

run_cmd "$DEFAULT_IDE $FILE_PATH$FILE"