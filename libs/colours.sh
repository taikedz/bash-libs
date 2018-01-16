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
