#!/bin/bash

### autohelp:print Usage:bbuild
# Write your help as documentation comments in your script
#
# If you need to output the help from a running script, call the
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
###/doc

HELPCHAR='#'

function autohelp:print {
	local USAGESTRING="${1:-}"; shift
	local TARGETFILE="${1:-}"; shift
	: ${USAGESTRING=help}
	: ${TARGETFILE=$0}

        echo -e "\n$(basename "$TARGETFILE")\n===\n"
        local SECSTART='^\s*'"$HELPCHAR$HELPCHAR$HELPCHAR"'\s+(.+?)\s+Usage:'"$USAGESTRING"'\s*$'
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

        if [[ -f "$insec" ]]; then
                echo "WARNING: Non-terminated help block." 1>&2
		rm "$insec"
        fi
	echo ""
}

### automatic help Usage:main
#
# automatically call help if "--help" is detected in arguments
#
###/doc
if [[ "$@" =~ --help ]]; then
	cols="$(tput cols)"
	autohelp:print | fold -w "$cols" -s
	exit 0
fi