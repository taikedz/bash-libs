#!/bin/bash

### doinclusions Usage:bbuild
#
# Utility to allow developer-defined inclusion directives in files being processed.
#
###/doc

#%include searchpaths.sh abspath.sh

### includefile:include INFILE PATTERN [SEARCHPATHS] Usage:bbuild
#
# Inserts the contents of the files specified on lines matched by PATTERN into the stream of INFILE
# at the location they are declared.
#
# Inclusion directives must stand alone on their lines.
#
# Example:
#
# 	This is some content in the FILE called myfile.txt
#
# 	@@include external_file.txt external_2.txt
#
# 	We cannot include in the middle of a line. The following
# 	line will not be processed:
#
# 	( some line with @@inclusion file1 file2 )
#
# We can call this to include the contents of each file:
#
# 	includefile:include myfile.txt '@@include'
#
# The result will be something like
#
# 	This is some content in the FILE called myfile.txt
#
# 	(file1 contents)
#
# 	(file2 contents)
#
# 	We cannot include in the middle of a line. The following
# 	line will not be processed:
#
# 	( some line with @@inclusion file1 file2 )
#
# Note that files for inclusion MUST NOT have spaces in their names, or in their paths.
#
# SEARCH PATHS
# ============
#
# You can specify a colon (":") -separated list of directories wherein to search for files by calling
#
# 	includefile:include FILE PAT SEARCHPATHS
#
# This will search for the inclusions specified only along the specified paths. Example:
#
# 	includefile:include myfile.html '//!addstyle' "./importedstyles:$HOME/.local/lib/styles:/etc/htmlthing/styles"
# 
# This will seek to include the files named in the inclusion line of myfile.html first from a local ./importedstyles,
#  then from a general home configuration, and finally if it has found the file in neither the previous, it will be
#  searched for in the global configuration.
#
# If not specified, the default search path is simply the containing directory of myfile.html.
#
###/doc

function includefile:include {
	local INFILE="$1"; shift
	local PATTERN="$1"; shift
	local PATHS="$*"

	 while read inline; do
		out:debug "[36;1mInclusion target: $inline[0m"
	 	local pos="${inline%%:*}"
		inline="${inline#*:}"

		local inclusiontargets="${inline#$PATTERN }"

		# reverse inclusion targets
		# to insert always at same line, but preserve order of declaration
		local revintar=
		for targetfile in $inclusiontargets ; do
			revintar="$targetfile $revintar"
		done

		for targetfile in $revintar; do
			if [[ -z "$targetfile" ]]; then continue; fi
			local filepath="$(searchpaths:file_from "$PATHS" "$targetfile")"
			if [[ ! -f "$filepath" ]]; then
				out:warn "Could not find $targetfile in any of $PATHS"
				return 1
			fi
			includefile:fileinsert "$filepath" "$pos" "$INFILE"
		done

		sed "$pos d" -i "$INFILE"
	 done < <(grep -P "^$PATTERN" "$INFILE" -n | sort -r -n)
}

### includefile:fileinsert SOURCEFILE POSITION TARGETFILE Usage:bbuild
#
# Insert the contents of SOURCEFILE into TARGETFILE after line at POSITION
#
###/doc
function includefile:fileinsert {
	local SOURCEFILE="$(abspath:simple $1)"; shift
	local POSITION="$1"; shift
	local TARGETFILE="$1"; shift

	local SKIPFILE="$(includefile:getskipfile "$TARGETFILE")"

	if includefile:registerfile "$SKIPFILE" "$SOURCEFILE"; then
		out:debug "Inserting $SOURCEFILE at $TARGETFILE:$POSITION"

		includefile:docallback "$SOURCEFILE" "$TARGETFILE"

		sed "$POSITION r $SOURCEFILE" -i "$TARGETFILE"
	fi
}

function includefile:docallback {
	if [[ -n "$FILEINCLUDES_CALLBACK" ]]; then
		"$FILEINCLUDES_CALLBACK" "$@"
	fi
}

# Initialize the temp file
function includefile:inittemp {
	echo > "$(includefile:getskipfile "$1")"
}

# Get skipfile for path
# getskipfile TARGETPATH
# prints a temp file path in /tmp
function includefile:getskipfile {
	local tmpdir=/tmp/bbinclude
	mkdir -p "$tmpdir"
	
	local hash="$(echo "$1"|sha1sum)"
	hash="${hash:0:6}"

	local skipfile="$tmpdir/$hash"
	touch "$skipfile"
	echo "$skipfile"
}

# Internal method
# Register that a file has previously been included
# Returns 1 if already registered
function includefile:registerfile {
	local SKIPFILE="$1"; shift
	local TARGETFILE="$1"; shift

	if includefile:isregistered "$SKIPFILE" "$TARGETFILE"; then
		return 1
	fi

	echo "$TARGETFILE" >> "$SKIPFILE"
}

# Internal method
# check if file has already been reigstered
# returns 0 if yes
# returns 1 otherwise
function includefile:isregistered {
	local SKIPFILE="$1"; shift
	local TARGETFILE="$1"; shift

	if grep -P -q "^$TARGETFILE$" "$SKIPFILE"; then
		return 0
	fi

	return 1
}
