#!/usr/bin/env bash
#
# adapters/clock.sh -- wall-clock adapter.
#
# The only function that reads the system clock. Tests stub this to
# get deterministic timestamps in filenames.

# clock_now_iso8601_utc emits an ISO-8601 UTC timestamp with no
# punctuation other than the trailing Z -- safe to embed in file
# names on every filesystem we target. Example: 20240805T112346Z.
function clock_now_iso8601_utc(){
	date -u +%Y%m%dT%H%M%SZ
}
