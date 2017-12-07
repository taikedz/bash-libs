#!/bin/bash

### Find a file given a path list Usage:bbuild
#
# Usage:
#
# 	searchpaths:file_from PATHDEF FILE
#
# Locate a file along a search path.
#
# EXAMPLE
#
# The following will look for each of the files
#  in order of preference of a local lib directory, a profile-wide one, then a system-
#  wide one.
#
# 	searchpaths:file_from "./lib:$HOME/.local/lib:/usr/local/lib" file
#
# Echoes the path of the first file found.
#
# Returns 1 on failure to find any file.
#
###/doc

function searchpaths:file_from {
	local PATHS="$1"; shift
	local FILE="$1"; shift

	out:debug "file [$FILE] from [$PATHS]"

	for path in $(echo "$PATHS"|tr ':' ' '); do
		out:debug "Try path: $path"
		local fpath="$path/$FILE"
		if [[ -f "$fpath" ]]; then
			echo "$fpath"
			return
		else
			out:debug "No $fpath"
		fi
	done
	return 1
}