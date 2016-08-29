# my command
export MY_SEARCH_DIR="$HOME/.opt /opt"
export MY_OPT_DIR="$HOME/.opt/my"
export MY_LIB_DIR="lib"

case "${1:-$(uname -m)}" in
	"x86_64") MY_LIB_DIR="$MY_LIB_DIR lib64" ;;
	"i"?"86") MY_LIB_DIR="$MY_LIB_DIR lib32" ;;
esac

add_to_path () {
	local VAR=$1
	shift
	case ":${!VAR}:" in
		*":$1:"*)
			[ $SILENT ] || echo "Found '$1' in $VAR already"
			;;
		"::")
			[ $SILENT ] || echo "Wrote '$1' in $VAR"
			export $VAR="$1"
			;;
		*)
			[ $SILENT ] || echo "Added '$1' to $VAR"
			export $VAR="$1:${!VAR}"
			;;
	esac
}

my () {
	while [ $# -gt 0 ]; do
		case $1 in
			'-h'|'--help')
				echo "Usage: my [--silent] [--absolute] DIR [...]"
				echo
				echo "Search for 'bin', 'lib', 'include' sub-directories and add them"
				echo "to the relevant environment variables (PATH, LD_LIBRARY_PATH, ...)."
				echo "Also source '.mydeps' if it exists. (used for dependencies)"
				echo
				echo "If --absolute is not specified, search in directories listed in MY_SEARCH_DIR:"
				local DIR
				for DIR in $MY_SEARCH_DIR; do
					echo -e "\t$DIR/<DIR>"
				done
				unset DIR
				echo
				echo "Use 'my --list' to get the list of found directories."
				echo "Use 'my --reset' to reset the environment variables."
				echo
				echo "Complete list of options:"
				echo -e "\t-v | --verbose         \texplain what has been done"
				echo -e "\t-q | --quiet | --silent\tonly print error messages"
				echo -e "\t-l | --list [DIR]      \tprint the list of found directories that begin with DIR"
				echo -e "\t-a | --absolute        \tassume DIR is an absolute path (do not search)"
				echo -e "\t--reset                \treset the environment to a minimal working set (assuming: $python)"
				return 0
				;;
			'-v'|'--verbose')
				local SILENT=
				;;
			'-q'|'--quiet'|'--silent')
				local SILENT=true
				;;
			'-l'|'--list')
				local DIR
				for DIR in $MY_SEARCH_DIR; do
					echo "Searching in '$DIR':"
					( cd $DIR; ls -d $2*/ )
				done
				return 0
				;;
			'-a'|'--absolute')
				local ABSOLUTE=true
				;;
			'--reset')
				[ $SILENT ] || echo "Reset environment"
				export PATH="" && [ $SILENT ] || echo "Erase PATH"
				unset LD_LIBRARY_PATH && [ $SILENT ] || echo "Erase LD_LIBRARY_PATH"
				unset LIBRARY_PATH && [ $SILENT ] || echo "Erase LIBRARY_PATH"
				unset PKG_CONFIG_PATH && [ $SILENT ] || echo "Erase PKG_CONFIG_PATH"
				unset PYTHONPATH && [ $SILENT ] || echo "Erase PYTHONPATH"
				unset CPATH && [ $SILENT ] || echo "Erase CPATH"
				unset MANPATH && [ $SILENT ] || echo "Erase MANPATH"
				[ $SILENT ] || echo "Bootstrap environment"
				add_to_path PATH "/bin"
				add_to_path PATH "/sbin"
				add_to_path PATH "/usr/bin"
				add_to_path PATH "/usr/sbin"
				[ $SILENT ] || echo "Finalize environment"
				my --absolute "/" "/usr"
				;;
			'-'*)
				echo "my: unrecognized option '$1'"
				echo "Try 'my --help' for more information."
				return 1
				;;
			*)
				break
				;;
		esac
		shift
	done

	while [ $# -gt 0 ]; do
		local DIR

		if [ $ABSOLUTE ]; then
			[ -d "$1" ] && DIR="$1"
		else
			local SDIR
			for SDIR in $MY_SEARCH_DIR; do
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
			&& add_to_path PATH "$DIR/bin"
		[ -d "$DIR/sbin" ] \
			&& add_to_path PATH "$DIR/sbin"

		local LIB
		for LIB in $MY_LIB_DIR; do
			if [ -d "$DIR/$LIB" ]; then
				add_to_path LD_LIBRARY_PATH "$DIR/$LIB"
				add_to_path LIBRARY_PATH "$DIR/$LIB"
				[ -d "$DIR/$LIB/pkgconfig" ] \
					&& add_to_path PKG_CONFIG_PATH "$DIR/$LIB/pkgconfig"
				local PYTHON
				for PYTHON in "$DIR/$LIB/python"*; do
					local PYTHON_VAR="${PYTHON#$DIR/$LIB/python}"
					PYTHON_VAR="PYTHON${PYTHON_VAR/.}_PATH"
					[ -d "$PYTHON/site-packages" ] \
						&& add_to_path $PYTHON_VAR "$PYTHON/site-packages"
				done
				unset PYTHON
			fi
		done
		unset LIB

		[ -d "$DIR/include" ] \
			&& add_to_path CPATH "$DIR/include"

		[ -d "$DIR/man" ] \
			&& add_to_path MANPATH "$DIR/man"
		[ -d "$DIR/share/man" ] \
			&& add_to_path MANPATH "$DIR/share/man"

		[ -f "$DIR/.mydeps" ] \
			&& source "$DIR/.mydeps"

		unset DIR
		shift
	done

	PATH="${PATH/"$MY_OPT_DIR/bin:"}"
	PATH="$MY_OPT_DIR/bin:$PATH"
}

export -f add_to_path my
