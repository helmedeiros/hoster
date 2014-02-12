#!/usr/bin/env bash
#
# hoster.sh - An host file controler;
#
# Usage:
#
#     # Edit the default host file
#      hoster.sh -e
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      hoster -p -e

source $(dirname $0)/commands.sh
source $(dirname $0)/builtin/handle_options.sh
source $(dirname $0)/builtin/defaults.sh

define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
handle_options $@;