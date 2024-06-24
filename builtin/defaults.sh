#!/usr/bin/env bash
#
# shellcheck source=builtin/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/os.sh"

# Supported environment identifiers, in display order.
environments=(lcl dev hlg prod);

function define_defaults(){
    DEFAULT_IDE=$1;

    FILE_PATH=$2;
    FILE=$3;

    network=$4;

    HOST_FILE="$(hoster_os_host_file)";
    HOST_PATH="$(dirname "$HOST_FILE")";
    HOST_DEFAULT_FOLDER=".hosts";
}