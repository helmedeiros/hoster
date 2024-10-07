#!/usr/bin/env bash
#
# Bash completion for hoster.
#
# To install:
#
#   source scripts/completion.bash
#
# Or copy to /usr/local/etc/bash_completion.d/hoster on macOS,
# or /etc/bash_completion.d/hoster on Linux.

_hoster_complete() {
	local cur prev words cword
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	local subcommands="add apply clean diff edit export import init list remove rm status validate"
	local env_flags="--dev --hlg --lcl --prod -d -h -l -p"
	local globals="--help --version --verbose -v"

	# First positional after "hoster" -> subcommand or global flag.
	if [ "$COMP_CWORD" -eq 1 ]; then
		# shellcheck disable=SC2207
		COMPREPLY=( $(compgen -W "$subcommands $globals" -- "$cur") )
		return 0
	fi

	# After a subcommand that takes an environment flag, suggest those.
	case "${COMP_WORDS[1]}" in
		add|apply|clean|diff|edit|list|remove|rm)
			if [[ "$cur" == -* ]]; then
				# shellcheck disable=SC2207
				COMPREPLY=( $(compgen -W "$env_flags" -- "$cur") )
				return 0
			fi
			;;
		import)
			# shellcheck disable=SC2207
			COMPREPLY=( $(compgen -f -- "$cur") )
			return 0
			;;
	esac

	return 0
}

complete -F _hoster_complete hoster
complete -F _hoster_complete hoster.sh
