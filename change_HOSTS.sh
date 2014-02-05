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

define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
handle_options $@;
set_path;

run_cmd "mv $FILE_PATH/Hosts $FILE_PATH/tmp"
run_cmd "cp $FILE_PATH$FILE $FILE_PATH/Hosts"