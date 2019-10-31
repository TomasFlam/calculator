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
	ansi_color 6  # cyan
	printf '$ '
	escape "$@"
	printf '\n'
	ansi_reset

	local __exit_code=0
	"$@" || __exit_code=$?

	if [ $__exit_code -eq 0 ]; then
		ansi_color 2  # green
	else
		ansi_color 1  # red
	fi >&2
	printf '%s ' $__exit_code
	escape "$@"
	printf '\n'
	ansi_reset

	return $__exit_code
}
