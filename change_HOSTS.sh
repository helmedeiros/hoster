#!/usr/bin/env bash
#
# change_HOST.sh - An host file editor;
#
# Usage:
#
#     # Edit the default host file
#      ./change_HOST.sh
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      ./change_HOST.sh -l 
source $(dirname $0)/commands.sh
source $(dirname $0)/builtin/handle_options.sh
source $(dirname $0)/builtin/paths.sh
source $(dirname $0)/builtin/defaults.sh

HOST_PATH="/private/etc";

define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
handle_options $@;
set_path;

run_cmd "sudo mv $HOST_PATH/Hosts $HOST_PATH/tmp"
run_cmd "sudo cp $FILE_PATH$FILE $HOST_PATH/Hosts"