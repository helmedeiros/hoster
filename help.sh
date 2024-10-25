#!/usr/bin/env bash
#
# hoster helps messages.
hoster_usage_string="$progname [--help] [--version] [--verbose] <command> [<args>]";

function list_commands(){
	printf "usage: %s\n\n" "$hoster_usage_string";
	
	list_common_cmds_help
}


function list_common_cmds_help(){
	echo "The most commonly used $(basename "$0") commands are";
	echo "    add   	Add a new HOST to current repository into a specific environment.";
	echo "    apply 	Apply an environment's hosts to the system hosts file.";
	echo "    clean 	Remove the current project's entries from the system hosts file.";
	echo "    diff  	Preview what apply would change against the current state.";
	echo "    edit  	Open the host file defined to be used.";
	echo "    export	Dump every environment as JSON (stdout).";
	echo "    import	Load every environment from a JSON file produced by export.";
	echo "    init  	Create an empty host repository in the current folder.";
	echo "    list  	List all hosts for a specific project.";
	echo "    remove	Remove a host from a specific environment.";
	echo "    status  	Show which environments of the current project are applied.";
	echo "    validate	Sanity-check the project files for malformed IPs and duplicates.";
	echo "    doctor  	Diagnose the hoster install: deps, PATH, host file resolution.";
}