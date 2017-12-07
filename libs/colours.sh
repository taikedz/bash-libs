#!/bin/bash

### Colours for bash Usage:bbuild
# A series of colour flags for use in outputs.
#
# Example:
# 	
# 	echo "${CRED}Some red text ${CBBLU} some blue text $CDEF some text in the terminal's default colour"
#
# Colours available:
#
# CDEF -- switches to the terminal default
#
# CRED, CBRED -- red, bold red
# CGRN, CBGRN -- green, bold green
# CYEL, CBYEL -- yellow, bold yellow
# CBLU, CBBLU -- blue, bold blue
# CPUR, CBPUR -- purple, bold purple
#
###/doc

export CRED="\033[0;31m"
export CGRN="\033[0;32m"
export CYEL="\033[0;33m"
export CBLU="\033[0;34m"
export CPUR="\033[0;35m"
export CBRED="\033[1;31m"
export CBGRN="\033[1;32m"
export CBYEL="\033[1;33m"
export CBBLU="\033[1;34m"
export CBPUR="\033[1;35m"
export CDEF="\033[0m"
