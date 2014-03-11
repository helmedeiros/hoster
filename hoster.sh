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

HOST_DEFAULT_FOLDER=".hosts";

cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
cmd_handle_options $@;
cmd_execute_options $@;