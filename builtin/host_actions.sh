#!/usr/bin/env bash
#
function hosts_init(){
	FOLDER=$(pwd);
	HOSTS_FOLDER="$FOLDER/.hosts";

	echo "Initialized empty Hosts repository in $HOSTS_FOLDER" >&2
	run_cmd "mkdir $HOSTS_FOLDER";
	run_cmd "touch $HOSTS_FOLDER/hosts.lch $HOSTS_FOLDER/hosts.dev $HOSTS_FOLDER/hosts.hml $HOSTS_FOLDER/hosts.prd";	
}