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

    APPLY_TMP_NAME="Hosts.apply.tmp";
    OCCURRENCE_TMP_NAME="Hosts.out.tmp";

    # Where atomic backups of the system hosts file are stored before
    # any apply/clean mutation. Relative to the project root so each
    # project carries its own history.
    HOST_BACKUP_DIR=".hosts/backup";
}