#!/usr/bin/env bash
# my command
export MY_SEARCH_DIRS="$HOME/.opt /opt"
export MY_OPT_DIR="$HOME/.opt/my"
export MY_LIB_DIRS="lib"

case "${1:-$(uname -m)}" in
	"x86_64") MY_LIB_DIRS="$MY_LIB_DIRS lib64" ;;
	"i"?"86") MY_LIB_DIRS="$MY_LIB_DIRS lib32" ;;
esac

source $MY_OPT_DIR/prepend.sh

my () {
	while [ $# -gt 0 ]; do
		case $1 in
			'-h'|'--help')
				echo "Usage: my [--silent] [--reset] [--absolute] DIR [...]"
				echo
				echo "Search for 'bin', 'lib', 'include' sub-directories and add them"
				echo "to the relevant environment variables (PATH, LD_LIBRARY_PATH, ...)."
				echo "Also source '.mydeps' if it exists. (used for dependencies)"
				echo
				echo "If --reset is specified, reset the relevant environment variable."
				echo
				echo "If --absolute is not specified, search in directories listed in MY_SEARCH_DIRS:"
				local DIR
				for DIR in $MY_SEARCH_DIRS; do
					echo -e "\t$DIR/<DIR>"
				done
				unset DIR
				echo
				echo "Use 'my --list' to get the list of found directories."
				echo
				echo "Complete list of options:"
				echo -e "\t-v | --verbose         \texplain what has been done"
				echo -e "\t-q | --quiet | --silent\tonly print error messages"
				echo -e "\t-l | --list [DIR]      \tprint the list of found directories that begin with DIR"
				echo -e "\t-a | --absolute        \tassume DIR is an absolute path (do not search)"
				echo -e "\t--reset                \treset the environment to a minimal working set"
				return 0 ;;
			'-v'|'--verbose')
				local SILENT= ;;
			'-q'|'--quiet'|'--silent')
				local SILENT=true ;;
			'-l'|'--list')
				local DIR
				for DIR in $MY_SEARCH_DIRS; do
					echo "Searching in '$DIR':"
					( cd $DIR; ls -d $2*/ )
				done
				return 0 ;;
			'-a'|'--absolute')
				local ABSOLUTE=true ;;
			'--reset')
				[ $SILENT ] || echo "reset PATH"
				export PATH=''
				[ $SILENT ] || echo "reset LD_LIBRARY_PATH"
				unset LD_LIBRARY_PATH
				[ $SILENT ] || echo "reset LIBRARY_PATH"
				unset LIBRARY_PATH
				[ $SILENT ] || echo "reset PKG_CONFIG_PATH"
				unset PKG_CONFIG_PATH
				[ $SILENT ] || echo "reset PYTHONPATH ${!MY_PYTHON*}"
				unset PYTHONPATH ${!MY_PYTHON*}
				[ $SILENT ] || echo "reset CPATH"
				unset CPATH
				[ $SILENT ] || echo "reset MANPATH"
				unset MANPATH
				my --absolute "/" "/usr" ;;
			'-'*)
				echo "my: unrecognized option '$1'"
				echo "Try 'my --help' for more information."
				return 1 ;;
			*)
				break ;;
		esac
		shift
	done

	while [ $# -gt 0 ]; do
		local DIR

		if [ $ABSOLUTE ]; then
			[ -d "$1" ] && DIR="$1"
		else
			local SDIR
			for SDIR in $MY_SEARCH_DIRS; do
				if [ -d "$SDIR/$1" ]; then
					DIR="$SDIR/$1"
					break
				fi
			done
			unset SDIR
		fi

		if [ ! "$DIR" ] || [ ! -d "$DIR" ]; then
			echo "my: could not find '$1' directory"
			echo "Try 'my --list' for a list of directories."
			return 1
		fi

		DIR="${DIR%/}"

		[ -d "$DIR/bin" ] \
			&& prepend_path PATH "$DIR/bin"
		[ -d "$DIR/sbin" ] \
			&& prepend_path PATH "$DIR/sbin"

		local LIB
		for LIB in $MY_LIB_DIRS; do
			if [ -d "$DIR/$LIB" ]; then
				prepend_path LD_LIBRARY_PATH "$DIR/$LIB"
				prepend_path LIBRARY_PATH "$DIR/$LIB"
				[ -d "$DIR/$LIB/pkgconfig" ] \
					&& prepend_path PKG_CONFIG_PATH "$DIR/$LIB/pkgconfig"
				local PYTHON
				for PYTHON in "$DIR/$LIB/python"*; do
					local PYTHON_VAR="${PYTHON#$DIR/$LIB/python}"
					PYTHON_VAR="MY_PYTHON${PYTHON_VAR/.}_PATH"
					[ -d "$PYTHON/site-packages" ] \
						&& prepend_path $PYTHON_VAR "$PYTHON/site-packages"
					unset PYTHON_VAR
				done
				unset PYTHON
			fi
		done
		unset LIB

		[ -d "$DIR/include" ] \
			&& prepend_path CPATH "$DIR/include"

		[ -d "$DIR/man" ] \
			&& prepend_path MANPATH "$DIR/man"
		[ -d "$DIR/share/man" ] \
			&& prepend_path MANPATH "$DIR/share/man"

		[ -f "$DIR/.mydeps" ] \
			&& source "$DIR/.mydeps"

		unset DIR
		shift
	done

	prepend_path PATH "$MY_OPT_DIR/bin"
}

export -f my
