#!/bin/bash

#%include colours.sh

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

### out:debug MESSAGE Usage:bbuild
# print a blue debug message to stderr
# only prints if MODE_DEBUG is set to "true"
###/doc
function out:debug {
	if [[ "$MODE_DEBUG" = true ]]; then
		echo -e "${CBBLU}DEBUG: $CBLU$*$CDEF" 1>&2
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
	OUTPUT_BUFFER_defer="${OUTPUT_BUFFER_defer}\n$*"
}

### out:flush HANDLER Usage:bbuild
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
	[[ -n "$*" ]] || out:fail "Did not provide a command for buffered output\n\n${OUTPUT_BUFFER_defer:-}"

	[[ -n "${OUTPUT_BUFFER_defer:-}" ]] || return

	"$@" "$OUTPUT_BUFFER_defer"
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
# Requires debug mode set to true
#
# When the script runs, the message is printed with a propmt, and execution pauses.
#
# Type `exit`, `quit` or `stop` to stop the program. If the breakpoint is in a subshell,
#  execution from after the subshell will be resumed.
#
# Press return to continue execution.
#
###/doc

function out:break {
	[[ "$MODE_DEBUG" = true ]] || return

	read -p "${CRED}BREAKPOINT: $* >$CDEF " >&2
	if [[ "$REPLY" =~ quit|exit|stop ]]; then
		out:fail "ABORT"
	fi
}

[[ "$MODE_DEBUG_VERBOSE" = true ]] && set -x || :
