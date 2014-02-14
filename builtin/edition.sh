#!/usr/bin/env bash
#

function set_configuration(){
	HOST_PATH="/private/etc";
	set_path;
	run_cmd "sudo cp $HOST_PATH/Hosts $HOST_PATH/tmp"
	run_cmd "sudo cp $FILE_PATH$FILE $HOST_PATH/Hosts"
}