#!/bin/bash

### Verification script Usage:help
# Build scripts and run unit tests
#
# [norm=true] [runtests=false] [bbflags='-c'] ./verify [LIBFILES ...]
#
# * `norm=true` : do not remove test artifacts
# * `runtests=false` : do not run unit tests, just check that he files build
# * `bbflags='-c'` : run shellcheck (via `bbuild` feature)
#
# Any LIBFILE must be in the form of "./lib/SOMEFILE" , the corresponding test
#  that will be searched for wil then be "./tests/test-SOMEFILE"
###/doc

#!/bin/bash

### autohelp:print [ SECTION [FILE] ] Usage:bbuild
# Write your help as documentation comments in your script
#
# If you need to output the help from your script, or a file, call the
# `autohelp:print` function and it will print the help documentation
# in the current script to stdout
#
# A help comment looks like this:
#
#	### <title> Usage:help
#	#
#	# <some content>
#	#
#	# end with "###/doc" on its own line (whitespaces before
#	# and after are OK)
#	#
#	###/doc
#
# You can set a different help section by specifying a subsection
#
# 	autohelp:print section2
#
# > This would print a section defined in this way:
#
# 	### Some title Usage:section2
# 	# <some content>
# 	###/doc
#
# You can set a different comment character by setting the 'HELPCHAR' environment variable:
#
# 	HELPCHAR=%
#
###/doc

HELPCHAR='#'

function autohelp:print {
	local SECTION_STRING="${1:-}"; shift || :
	local TARGETFILE="${1:-}"; shift || :
	[[ -n "$SECTION_STRING" ]] || SECTION_STRING=help
	[[ -n "$TARGETFILE" ]] || TARGETFILE="$0"

        echo -e "\n$(basename "$TARGETFILE")\n===\n"
        local SECSTART='^\s*'"$HELPCHAR$HELPCHAR$HELPCHAR"'\s+(.+?)\s+Usage:'"$SECTION_STRING"'\s*$'
        local SECEND='^\s*'"$HELPCHAR$HELPCHAR$HELPCHAR"'\s*/doc\s*$'
        local insec=false

        while read secline; do
                if [[ "$secline" =~ $SECSTART ]]; then
                        insec=true
                        echo -e "\n${BASH_REMATCH[1]}\n---\n"

                elif [[ "$insec" = true ]]; then
                        if [[ "$secline" =~ $SECEND ]]; then
                                insec=false
                        else
				echo "$secline" | sed -r "s/^\s*$HELPCHAR//g"
                        fi
                fi
        done < "$TARGETFILE"

        if [[ "$insec" = true ]]; then
                echo "WARNING: Non-terminated help block." 1>&2
        fi
	echo ""
}

### autohelp:paged Usage:bbuild
#
# Display the help in the pager defined in the PAGER environment variable
#
###/doc
function autohelp:paged {
	: ${PAGER=less}
	autohelp:print "$@" | $PAGER
}

### autohelp:check Usage:bbuild
#
# Automatically print help and exit if "--help" is detected in arguments
#
# Example use:
#
#	#!/bin/bash
#
#	### Some help Usage:help
#	#
#	# Some help text
#	#
#	###/doc
#
#	#%include autohelp.sh
#
#	main() {
#		autohelp:check "$@"
#
#		# now add your code
#	}
#
#	main "$@"
#
###/doc
autohelp:check() {
	if [[ "$*" =~ --help ]]; then
		cols="$(tput cols)"
		autohelp:print | fold -w "$cols" -s || autohelp:print
		exit 0
	fi
}
#!/bin/bash


### Console output handlers Usage:bbuild
#
# Write data to console stderr using colouring
#
###/doc

### Environment Variables Usage:bbuild
#
# MODE_DEBUG : set to 'true' to enable debugging output
# MODE_DEBUG_VERBOSE : set to 'true' to enable command echoing
#
###/doc

: ${MODE_DEBUG=false}
: ${MODE_DEBUG_VERBOSE=false}

# Internal
function out:buffer_initialize {
	OUTPUT_BUFFER_defer=(:)
}
out:buffer_initialize

### out:debug MESSAGE Usage:bbuild
# print a blue debug message to stderr
# only prints if MODE_DEBUG is set to "true"
###/doc
function out:debug {
	if [[ "$MODE_DEBUG" = true ]]; then
		echo -e "${CBBLU}DEBUG: $CBLU$*$CDEF" 1>&2
	fi
}

### out:debug:fork [MARKER] Usage:bbuild
#
# Pipe the data coming through stdin to stdout
#
# If debug mode is on, *also* write the same data to stderr, each line preceded by MARKER
#
# Insert this debug fork into pipes to see their output
#
###/doc
function out:debug:fork {
	if [[ "$MODE_DEBUG" = true ]]; then
		local MARKER="${1:-DEBUG: }"; shift || :

		cat - | sed -r "s/^/$MARKER/" | tee -a /dev/stderr
	else
		cat -
	fi
}

### out:info MESSAGE Usage:bbuild
# print a green informational message to stderr
###/doc
function out:info {
	echo -e "$CGRN$*$CDEF" 1>&2
}

### out:warn MESSAGE Usage:bbuild
# print a yellow warning message to stderr
###/doc
function out:warn {
	echo -e "${CBYEL}WARN: $CYEL$*$CDEF" 1>&2
}

### out:defer MESSAGE Usage:bbuild
# Store a message in the output buffer for later use
###/doc
function out:defer {
	OUTPUT_BUFFER_defer[${#OUTPUT_BUFFER_defer[@]}]="$*"
}

### out:flush HANDLER ... Usage:bbuild
#
# Pass the output buffer to the command defined by HANDLER
# and empty the buffer
#
# Examples:
#
# 	out:flush echo -e
#
# 	out:flush out:warn
#
# (escaped newlines are added in the buffer, so `-e` option is
#  needed to process the escape sequences)
#
###/doc
function out:flush {
	[[ -n "$*" ]] || out:fail "Did not provide a command for buffered output\n\n${OUTPUT_BUFFER_defer[*]}"

	[[ "${#OUTPUT_BUFFER_defer[@]}" -gt 1 ]] || return

	for buffer_line in "${OUTPUT_BUFFER_defer[@]:1}"; do
		"$@" "$buffer_line"
	done

	out:buffer_initialize
}

### out:fail [CODE] MESSAGE Usage:bbuild
# print a red failure message to stderr and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function out:fail {
	local ERCODE=127
	local numpat='^[0-9]+$'

	if [[ "$1" =~ $numpat ]]; then
		ERCODE="$1"; shift
	fi

	echo -e "${CBRED}ERROR FAIL: $CRED$*$CDEF" 1>&2
	exit $ERCODE
}

### out:error MESSAGE Usage:bbuild
# print a red error message to stderr
#
# unlike out:fail, does not cause script exit
###/doc
function out:error {
	echo -e "${CBRED}ERROR: ${CRED}$*$CDEF" 1>&2
}

### out:dump Usage:bbuild
#
# Dump stdin contents to console stderr. Requires debug mode.
#
# Example
#
# 	action_command 2>&1 | out:dump
#
###/doc

function out:dump {
	echo -e -n "${CBPUR}$*" 1>&2
	echo -e -n "$CPUR" 1>&2
	cat - 1>&2
	echo -e -n "$CDEF" 1>&2
}

### out:break MESSAGE Usage:bbuild
#
# Add break points to a script
#
# Requires MODE_DEBUG set to true
#
# When the script runs, the message is printed with a propmt, and execution pauses.
#
# Press return to continue execution.
#
# Type `exit`, `quit` or `stop` to stop the program. If the breakpoint is in a subshell,
#  execution from after the subshell will be resumed.
#
###/doc

function out:break {
	[[ "$MODE_DEBUG" = true ]] || return

	read -p "${CRED}BREAKPOINT: $* >$CDEF " >&2
	if [[ "$REPLY" =~ quit|exit|stop ]]; then
		out:fail "ABORT"
	fi
}

if [[ "$MODE_DEBUG_VERBOSE" = true ]]; then
	set -x
fi
#!/bin/bash

### Colours for bash Usage:bbuild
# A series of colour flags for use in outputs.
#
# Example:
# 	
# 	echo -e "${CRED}Some red text ${CBBLU} some blue text $CDEF some text in the terminal's default colour"
#
# Requires processing of escape characters.
#
# Colours available:
#
# CRED, CBRED, HLRED -- red, bold red, highlight red
# CGRN, CBGRN, HLGRN -- green, bold green, highlight green
# CYEL, CBYEL, HLYEL -- yellow, bold yellow, highlight yellow
# CBLU, CBBLU, HLBLU -- blue, bold blue, highlight blue
# CPUR, CBPUR, HLPUR -- purple, bold purple, highlight purple
# CTEA, CBTEA, HLTEA -- teal, bold teal, highlight teal
#
# CDEF -- switches to the terminal default
# CUNL -- add underline
#
# Note that highlight and underline must be applied or re-applied after specifying a colour.
#
###/doc

export CRED="\033[0;31m"
export CGRN="\033[0;32m"
export CYEL="\033[0;33m"
export CBLU="\033[0;34m"
export CPUR="\033[0;35m"
export CTEA="\033[0;36m"

export CBRED="\033[1;31m"
export CBGRN="\033[1;32m"
export CBYEL="\033[1;33m"
export CBBLU="\033[1;34m"
export CBPUR="\033[1;35m"
export CBTEA="\033[1;36m"

export HLRED="\033[41m"
export HLGRN="\033[42m"
export HLYEL="\033[43m"
export HLBLU="\033[44m"
export HLPUR="\033[45m"
export HLTEA="\033[46m"

export CDEF="\033[0m"
### runmain SCRIPTNAME FUNCTION [ARGUMENTS ...] Usage:bbuild
#
# Runs the function FUNCTION with ARGUMENTS, only if the runtime
# name of the script matches SCRIPTNAME
#
# This allows you include a main-like function in your library
# that only runs if you use your lib as an executabl itself.
#
# For example, an image archiver could be:
#
# 	function archive_images {
# 		tar czf "$1.tgz" "$@"
# 	}
#
# 	runmain archiveimages.sh archive_images "$@"
#
# When included a different script, the runmain call does not fire the lib's function
#
# If the lib is compiled/made executable, and named "archiveimages.sh", the function runs.
#
# This is similar to `if __name__ == "__main__"` clauses in python
#
###/doc

function runmain {
	local required_name="$1"; shift
	local funcall="$1"; shift
	local scriptname="$(basename "$0")"

	if [[ "$required_name" = "$scriptname" ]]; then
		"$funcall" "$@"
	fi
}

cd "$(dirname "$0")"
export BUILDOUTD=/tmp
export BBPATH=libs/

items=0
fails=0
: ${runtests=true}

set_executable() {
	if [[ -z "${BBEXEC:-}" ]]; then
		export BBEXEC=bbuild
	fi

	if [[ ! -f "$BBEXEC" ]] && ! which "$BBEXEC" >/dev/null 2>/dev/null; then
		out:fail 1 "Cannot use [$BBEXEC] to run builds - no such file or command"
	fi

	out:info "Build using \`$BBEXEC\` command"
}

set_targets() {
	targets=(libs/*.sh)

	if [[ "$#" -gt 0 ]]; then
		targets=("$@")
	fi
}

rmfile() {
	[[ "${norm:-}" = true ]] && return || :

	rm "$@" || :
}

run_build_test() {
	local scriptname="$1"; shift

	"$BBEXEC" ${bbflags:-} "$libscript" || {
		fails=$((fails+1))
		continue
	}
}

run_unit_tests() {
	[[ "${runtests:-}" = true ]] || return

	local scriptname="$1"; shift
	local testname="test-$scriptname"
	local testsfile="tests/$testname"

	if [[ -f "$testsfile" ]]; then
		"$BBEXEC" "$testsfile"
		MODE_DEBUG="${MODE_DEBUG:-}" bash ${bashflags:-} "/tmp/$testname" || fails=$((fails+1))
	else
		out:warn "There is no $testsfile test file."
	fi
}

run_verification() {
	for libscript in "${targets[@]}"; do
		local scriptname="$(basename "$libscript")"

		items=$((items+1))

		run_build_test "$scriptname"

		run_unit_tests "$scriptname"

		rmfile "/tmp/$scriptname"
	done
}

main() {
	autohelp:check "$@"

	set_executable
	set_targets "$@"
	run_verification

	echo -e "\n\n\n"
	local endmsg="Verification --- Built $items items with $fails failures."

	if [[ "$fails" -gt 0 ]]; then
		out:fail "$fails" "$endmsg"
	else
		out:info "$endmsg"
	fi
}

time runmain verify.sh main "$@"
