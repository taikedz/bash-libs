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
# You can set a different comment character by setting the 'HELPCHAR' environment variable:
#
# 	HELPCHAR=%
# 	autohelp:print
#
# You can set a different help section by specifying the 'SECTION_STRING' variable
#
# 	SECTION_STRING=subsection autohelp:print
#
###/doc

HELPCHAR='#'

function autohelp:print {
	local SECTION_STRING="${1:-}"; shift
	local TARGETFILE="${1:-}"; shift
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

### automatic help Usage:main
#
# automatically call help if "--help" is detected in arguments
#
###/doc
if [[ "$*" =~ --help ]]; then
	cols="$(tput cols)"
	autohelp:print | fold -w "$cols" -s || autohelp:print
	exit 0
fi
