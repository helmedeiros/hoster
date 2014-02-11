#!/usr/bin/env bash
source $(dirname $0)/builtin/host_actions.sh
source $(dirname $0)/builtin/paths.sh


function run_cmd(){
	echo "Running: $1"
	$1

	if [ "$?" -ne "0" ]; then
	  echo "command failed: $1"
	  exit 1
	fi
}

function cmd_hosts_init(){ hosts_init; }

# Custom die function.
function die() { echo >&2 -e "\nERROR: $@\n"; exit 1; }