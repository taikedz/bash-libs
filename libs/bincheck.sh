##bash-libs: bincheck.sh @ %COMMITHASH%

### bincheck:get COMMANDS ... Usage:bbuild
#
# Return the first existing binary
#
# Useful for finding an appropriate binary when you know
# different systems may supply binaries under different names.
#
# Returns the full path from `which` for the first executable
# encountered.
#
# Example:
#
# 	bincheck:get markdown_py markdown ./mymarkdown
#
# Tries in turn to get a `markdown_py`, then a `markdown`, and then a local `./mymarkdown`
#
###/doc

bincheck:get() {
	local BINEXE=
	for binname in "$@"; do
		# Some implementations of `which` print error messages
		# Not useful here.
		BINEXE=$(which "$binname" 2>/dev/null)

		if [[ -n "$BINEXE" ]]; then
			echo "$BINEXE"
			return 0
		fi
	done
	return 1
}

### bincheck:has NAMES ... Usage:bbuild
#
# Determine if at least one of the binaries listed is present and installed on the system
#
###/doc

bincheck:has() {
	[[ -n "$(bincheck:get "$@")" ]]
}

### bincheck:path NAME Usage:bbuild
#
# Determine the actual path to the command
#
# Relative paths are not expanded.
#
###/doc

bincheck:path() {
	local binname="$1"; shift || :

	[[ "$binname" =~ / ]] && { 
		# A relative path cannot be resolved, just check existence
		[[ -e "$binname" ]] && echo "$binname" || return 1

	} || binname="$(which "$binname" 2>/dev/null)"

	# `which` failed
	[[ -n "$binname" ]] || return 1

	[[ -h "$binname" ]] && {

		local pointedname="$(ls -l "$binname"|grep -oP "$binname.+"|sed "s|$binname -> ||")"
		bincheck:path "$pointedname" ; return "$?"
	
	} || echo "$binname"
}
