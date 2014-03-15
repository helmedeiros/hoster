#!/usr/bin/env bash


function append_host(){
	run_cmd "sudo cp $1 $HOST_PATH/Hosts";
}