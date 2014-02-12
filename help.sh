#!/usr/bin/env bash
#
# hoster helps messages.
hoster_usage_string="$progname [--help] [--version] <command> [<args>]";

function list_commands(){
	printf "usage: %s\n\n" "$hoster_usage_string";
	
	list_common_cmds_help
}


function list_common_cmds_help(){
	echo "The most commonly used `basename $0` commands are";
	echo "    dev 	Define the DEVELOPMENT environment hosts to be used.";
	echo "    edit	Open the host file defined to be used.";
	echo "    hlg		Define the HOMOLOGATION environment hosts to be used.";
	echo "    init	Create an empty host repository in the current folder.";
	echo "    lcl		Define the LOCAL environment hosts to be used.";
	echo "    net		Check the network # [Ethernet | Wi-Fi | VPN] to chose specific files based on what will you do there.";
	echo "    prod	Define the PRODUCTION environment hosts to be used.";
	echo "    set		Set the host file defined to be used.";
}