##bash-libs: varify.sh @ %COMMITHASH%

### Varify Usage:bbuild
# Make a string into a valid variable name or file name
#
# Collapses any string of invalid characters into a single underscore
#
# For example
#
# 	varify:var "http://example.com"
#
# returns
#
# 	http_example.com
#
###/doc

### varify:var Usage:bbuild
#
# Valid characters for varify:var are:
#
# * a-z
# * A-Z
# * 0-9
# * underscore ("_")
###/doc
function varify:var {
	echo "$*" | sed -r 's/[^a-zA-Z0-9_]/_/g'
}

### varify:fil Usage:bbuild
#
# Valid characters for varify:fil are:
#
# * a-z
# * A-Z
# * 0-9
# * underscore ("_")
# * dash ("-")
# * period (".")
#
# Can be used to produce filenames.
#
###/doc
function varify:fil {
	echo "$*" | sed -r 's/[^a-zA-Z0-9_.-]/_/g'
}
