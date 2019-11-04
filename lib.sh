#!/usr/bin/env bash

set -e
set -o pipefail
set -u

export PROJECT_ROOT
PROJECT_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

export PATH
PATH="$PROJECT_ROOT/utils:$PATH"

ansi_color () {
	[ $# -eq 1 ] || return 2
	printf '\e[3%dm' "$1"
}

ansi_reset () {
	[ $# -eq 0 ] || return 2
	printf '\e[0m'
}

verbose () {
	local __print_command=yes
	local __print_success=yes
	local __print_failure=yes
	while [ $# -gt 0 ]; do
		case $1 in
			--only-failure)
				__print_command=no
				__print_success=no
				__print_failure=yes
				shift
				;;
			*)
				break
				;;
		esac
	done

	if [ "$__print_command" = yes ]; then
		ansi_color 6  # cyan
		printf '$ '
		escape "$@"
		printf '\n'
		ansi_reset
	fi

	local __exit_code=0
	"$@" || __exit_code=$?

	if {
		[ $__exit_code -eq 0 ] && [ "$__print_success" = yes ];
	} || {
		[ $__exit_code -ne 0 ] && [ "$__print_failure" = yes ];
	} then
		if [ $__exit_code -eq 0 ]; then
			ansi_color 2  # green
		else
			ansi_color 1  # red
		fi >&2
		printf '%s ' $__exit_code
		escape "$@"
		printf '\n'
		ansi_reset
	fi

	return $__exit_code
}
