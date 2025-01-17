#!/usr/bin/env bash
#
# os.sh - host operating system detection for hoster.
#
# Inspired by builtin/os.rb on the (abandoned) ruby branch.
# Exposes three predicates and one resolver:
#
#   hoster_os_is_macos
#   hoster_os_is_linux
#   hoster_os_is_windows
#   hoster_os_host_file   # path to the system hosts file

function hoster_os_is_macos(){
	[[ "$OSTYPE" == darwin* ]]
}

function hoster_os_is_linux(){
	[[ "$OSTYPE" == linux* ]]
}

function hoster_os_is_windows(){
	[[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys* || "$OSTYPE" == mingw* ]]
}

function hoster_os_host_file(){
	if hoster_os_is_macos; then
		echo "/private/etc/hosts"
	elif hoster_os_is_linux; then
		echo "/etc/hosts"
	elif hoster_os_is_windows; then
		echo "/c/Windows/System32/drivers/etc/hosts"
	else
		echo "/etc/hosts"
	fi
}
