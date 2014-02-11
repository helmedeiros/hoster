#!/usr/bin/env bash
#
# edit_HOST.sh - An host file editor;
#
# Usage:
#
#     # Edit the default host file
#      ./edit_HOST.sh
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      ./edit_HOST.sh -l 
source $(dirname $0)/commands.sh
source $(dirname $0)/builtin/handle_options.sh
source $(dirname $0)/builtin/defaults.sh

define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
handle_options $@;