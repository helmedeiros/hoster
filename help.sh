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
	echo "    add 	Add a new HOST to current repository into a specific environment.";
	echo "    edit	Open the host file defined to be used.";
	echo "    init	Create an empty host repository in the current folder.";
	echo "    list	List all hosts for a specific project.";
}