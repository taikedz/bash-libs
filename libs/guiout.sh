#!/bin/bash

### GUI Dialogs (guiout) Usage:bbuild
# 
# Try to display a graphical dialog
#
###/doc

# Internal function

### guiout:dialog MODE MESSAGE ... Usage:bbuild-internal
#
# Attempts to use one of zenity or xmessage to display a graphical dialog
#
# The MODE is one of `info`, `warn` or `fail`
#
###/doc

function guiout:dialog {
	local mode="$1"; shift || :
	if [[ -f /usr/bin/zenity ]]; then
		case "$mode" in
		info)
			zenity --info --text="$*" >/dev/null 2>&1
			;;
		warn)
			zenity --warning --text="$*" >/dev/null 2>&1
			;;
		fail)
			zenity --error --text="$*" >/dev/null 2>&1
			;;
		esac
	else
		case "$mode" in
		info)
			xmessage "INFO: $*" >/dev/null 2>&1
			;;
		warn)
			xmessage "WARN: $*" >/dev/null 2>&1
			;;
		fail)
			xmessage "FAIL: $*" >/dev/null 2>&1
			;;
		esac

	fi
}

### guiout:fail [ERRCODE] MESSAGE ... Usage:bbuild
#
# Display a failure dialog, and exit
#
###/doc

function guiout:fail {
	local errcode=127
	numpat="^[0-9]$"
	if [[ "$1" =~ $numpat ]] ; then
		errcode="$1"; shift || :
	fi
	guiout:dialog fail "$*"
	exit $errcode
}

### guiout:warn MESSAGE Usage:bbuild
#
# Display a warning dialog
#
###/doc

function guiout:warn {
	guiout:dialog warn "$*"
}

### guiout:info MESSAGE ... Usage:bbuild
#
# Display an info dialog
#
###/doc

function guiout:info {
	guiout:dialog info "$*"
}
