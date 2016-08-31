#!/usr/bin/env bash

prepend_path () {
	local VAR=$1
	shift
	export $VAR="${!VAR}:"
	while [ $# -gt 0 ]; do
		case "${!VAR}" in
			*":$1:"*)
				[ $SILENT ] || echo "'$1' removed from $VAR"
				export $VAR="${!VAR/":$1:"/:}" ;;
			"$1:"*)
				[ $SILENT ] || echo "'$1' is prefix of $VAR"
				shift ;;
			*)
				[ $SILENT ] || echo "'$1' prepended to $VAR"
				export $VAR="$1:${!VAR}";
				shift ;;
		esac
	done
	export $VAR="${!VAR%:}"
}

export -f prepend_path
