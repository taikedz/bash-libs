#!/bin/bash

#%include colours.sh

### Environment Variables Usage:bbuild
#
# MODE_DEBUG : set to 'yes' to enable debugging output
# MODE_DEBUG_VERBOSE : set to 'yes' to enable command echoing
#
###/doc


MODE_DEBUG=no
MODE_DEBUG_VERBOSE=no

### out:debug MESSAGE Usage:bbuild
# print a blue debug message to stderr
# only prints if MODE_DEBUG is set to "yes"
###/doc
function out:debug {
	if [[ "$MODE_DEBUG" = yes ]]; then
		echo -e "${CBBLU}DEBUG:$CBLU$*$CDEF" 1>&2
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
	echo -e "${CBYEL}WARN:$CYEL $*$CDEF" 1>&2
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

	echo -e "${CBRED}ERROR FAIL:$CRED$*$CDEF" 1>&2
	exit $ERCODE
}

function out:dump {
	echo -e -n "${CBPUR}$*" 1>&2
	echo -e -n "$CPUR" 1>&2
	cat - 1>&2
	echo -e -n "$CDEF" 1>&2
}

function out:break {
	[[ "$MODE_DEBUG" = yes ]] || return

	read -p "${CRED}BREAKPOINT: $* >$CDEF " >&2
	if [[ "$REPLY" =~ $(echo 'quit|exit|stop') ]]; then
		out:fail "ABORT"
	fi
}

[[ "$MODE_DEBUG_VERBOSE" = yes ]] && set -x || :