#!/bin/bash

### Varify Usage:bbuild
# Make a string into a valid variable name or file name
#
# Replaces any string of invalid characters into a "_"
#
# Valid characters for varify:var are:
#
# * a-z
# * A-Z
# * 0-9
# * underscore ("_")
#
# Valid characters for varify:fil are as above, plus:
#
# * dash ("-")
# * period (".")
#
# Can be used to produce filenames.
###/doc

function varify:var {
	echo "$*" | sed -r 's/[^a-zA-Z0-9_]/_/g'
}

function varify:fil {
	echo "$*" | sed -r 's/[^a-zA-Z0-9_.-]/_/g'
}
