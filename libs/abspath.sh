#!/bin/bash

### abspath:path RELATIVEPATH [ MAX ] Usage:bbuild
# Returns the absolute path of a file/directory
#
# MAX defines the maximum number of "../" relative items to process
#   default is 50
###/doc

function abspath:path {
	local workpath="$1" ; shift || :
	local max="${1:-50}" ; shift || :

	if [[ "${workpath:0:1}" != "/" ]]; then workpath="$PWD/$workpath"; fi

	workpath="$(abspath:collapse "$workpath")"
	abspath:resolve_dotdot "$workpath" "$max" | sed -r 's|(.)/$|\1|'
}

function abspath:collapse {
	echo "$1" | sed -r 's|/\./|/|g ; s|/\.$|| ; s|/+|/|g'
}

function abspath:resolve_dotdot {
	local workpath="$1"; shift || :
	local max="$1"; shift || :

	# Set a limit on how many iterations to perform
	# Only very obnoxious paths should fail
	for x in $(seq 1 $max); do
		# No more dot-dots - good to go
		if [[ ! "$workpath" =~ /\.\.(/|$) ]]; then
			echo "$workpath"
			return 0
		fi

		# Starts with an up-one at root - unresolvable
		if [[ "$workpath" =~ ^/\.\.(/|$) ]]; then
			return 1
		fi

		workpath="$(echo "$workpath"|sed -r 's@[^/]+/\.\.(/|$)@@')"
	done

	# A very obnoxious path was used.
	return 2
}
