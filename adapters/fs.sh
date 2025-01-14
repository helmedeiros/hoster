#!/usr/bin/env bash
#
# adapters/fs.sh -- filesystem adapter.
#
# Owns reads and writes to the project's backup directory. The clock
# stamp used in file names comes from adapters/clock.sh so tests can
# freeze time.

# fs_backup snapshots $HOST_FILE under
#   $TOP_LEVEL_FOLDER/$HOST_BACKUP_DIR/<timestamp>-<reason>.hosts
# and emits the absolute destination path on stdout.
function fs_backup(){
	local reason="${1:-mutation}"
	local backup_root="$TOP_LEVEL_FOLDER/$HOST_BACKUP_DIR"

	mkdir -p "$backup_root"

	local stamp
	stamp="$(clock_now_iso8601_utc)"
	local dest="$backup_root/${stamp}-${reason}.hosts"

	cp "$HOST_FILE" "$dest"
	hoster_log "Backed up $HOST_FILE -> $dest"
	echo "$dest"
}

# Compatibility shim: existing callers ask for hoster_backup. Keep
# the old name pointing at the adapter so this migration is a pure
# rename, not a behaviour change.
function hoster_backup(){
	fs_backup "$@"
}
