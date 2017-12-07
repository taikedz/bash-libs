### this: Info about the current command Usage:bbuild
#
# Get information about the current running app.
#
###/doc

#%include abspath.sh

### this:bin Usage:bbuild
# The name of the file running
###/doc
function this:bin {
	echo "$(basename "$0")"
}

### this:bindir Usage:bbuild
# The absolute path of the directory in which the command is running
###/doc
function this:bindir {
	echo "$(abspath:simple "$(dirname "$0")" )"
}
