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
source $(dirname $0)/builtin/paths.sh

FILE="Hosts";
FILE_PATH="/private/etc/";
network="Wi-Fi";

DEFAULT_IDE="sublime";

  
handle_options $@;
set_path;

run_cmd "$DEFAULT_IDE $FILE_PATH$FILE"