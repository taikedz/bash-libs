#!/bin/bash

### Logging facility Usage:bbuild
#
# By default, writes to <stderr>
#
###/doc

BBLOGFILE=/dev/stderr
LOGENTITY=$(basename "$0")

### LOG_LEVEL Usage:bbuild
#
# Log level environment variable. Set it to one of the predefined values:
#
# $LOG_LEVEL_FAIL - failures only
# $LOG_LEVEL_WARN - failures and warnings
# $LOG_LEVEL_INFO - failures, warnings and information
# $LOG_LEVEL_DEBUG - failures, warnings, info and debug
#
# Example:
#
# 	export LOG_LEVEL=$LOG_LEVEL_WARN
# 	command ...
#
###/doc

LOG_LEVEL=0

LOG_LEVEL_FAIL=0
LOG_LEVEL_WARN=0
LOG_LEVEL_INFO=0
LOG_LEVEL_DEBUG=0

# Handily determine that the minimal level threshold is met
function log:islevel {
	local req_level="$1"; shift

	[[ "$LOG_LEVEL" -ge "$req_level" ]]
}

### log:use_file LOGFILE Usage:bbuild
# Set the specified file as log file.
#
# If this fails, log is sent to stderr
###/doc
function log:use_file {
	local target_file="$1"; shift
	local standard_outputs="/dev/(stdout|stderr)"
	if [[ ! "$target_file" =~ $standard_outputs ]]; then

		echo "$LOGENTITY $(date +"%F %T") Selecting log file" >> "$target_file" || {
			local msg="Could not set the log file to [$target_file] ; moving to stderr"

			if [[ "$BBLOGFILE" != /dev/stderr ]]; then
				# leave a trace of this in the last log file
				log:warn "$msg"
			fi

			export BBLOGFILE=/dev/stderr
			log:warn "$msg"
		}
	fi
	export BBLOGFILE="$target_file"
}

### log:use_cwd Usage:bbuild
# Create a log file in the curent working directory
###/doc
function log:use_cwd {
	log:use_file "$PWD/$LOGENTITY.log"
}

### log:use_var Usage:bbuild
# Set the log location to /var/log/$SCRIPTNAME/...
#
# prints the log file in use to stderr
###/doc
function log:use_var {
	local logdir="/var/log/$LOGENTITY"
	local logfile="$(whoami)-$UID-$HOSTNAME.log"
	local tgtlog="$logdir/$logfile"

	mkdir -p "$(dirname "$tgtlog")" && touch "$tgtlog" || {
		log:use_file "/dev/stderr"
		out:warn "Could not create [$logfile] in [$logdir] - logging to stderr"
		return 1
	}

	log:use_file "$tgtlog"
}

### log:debug MESSAGE Usage:bbuild
# Print a debug message to the log
###/doc
function log:debug {
	log:islevel "$LOG_LEVEL_DEBUG" || return

	if [[ "$MODE_DEBUG" = yes ]]; then
		echo -e "$LOGENTITY $(date "+%F %T") DEBUG: $*" >>"$BBLOGFILE"
	fi
}

### log:info MESSAGE Usage:bbuild
# print an informational message to the log
###/doc
function log:info {
	log:islevel "$LOG_LEVEL_INFO" || return

	echo -e "$LOGENTITY $(date "+%F %T") INFO: $*" >>"$BBLOGFILE"
}

### log:warn MESSAGE Usage:bbuild
# print a warning message to the log
###/doc
function log:warn {
	log:islevel "$LOG_LEVEL_WARN" || return

	echo -e "$LOGENTITY $(date "+%F %T") WARN: $*" >>"$BBLOGFILE"
}

### log:fail [CODE] MESSAGE Usage:bbuild
# print a failure message to the log, and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function log:fail {
	log:islevel "$LOG_LEVEL_FAIL" || return

	local MSG=
	local ARG=
	local ERCODE=127
	local numpat='^[0-9]+$'

	if [[ "${1:-}" =~ $numpat ]]; then
		ERCODE="$1"
		shift
	fi

	echo "$LOGENTITY $(date "+%F %T") ERROR FAIL: $*" >>"$BBLOGFILE"
}

### log:dump Usage:bbuild
#
# Dump the stdin to the log.
#
# Requires level $LOG_LEVEL_DEBUG
#
# Example:
#
# 	action_command 2>&1 | log:dump
#
###/doc

function log:dump {
	log:debug "$* -------------¬"
	log:debug "$(cat -)"
	log:debug "______________/"
}
