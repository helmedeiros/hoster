#!/usr/bin/env bash
#
# adapters/sudo.sh -- privileged-operation chokepoint.
#
# Every place that needs to write the system hosts file goes
# through priv_run. Auditing what hoster does as root means reading
# this file. Tests override priv_run with a passthrough so the
# suite never actually escalates.

# priv_run executes its arguments as root via sudo. The arguments
# go through verbatim (no string-splitting via eval) which avoids
# the legacy run_cmd quoting hazards.
function priv_run(){
	sudo "$@"
}

# priv_run_str takes a single shell string and runs it via sudo
# under bash -c. Used only by callers that still build command
# strings (the run_cmd path). New code should prefer priv_run.
function priv_run_str(){
	sudo bash -c "$1"
}
