#%include abspath.sh

##bash-libs: this.sh @ %COMMITHASH%

### this: Info about the current command Usage:bbuild
#
# Get information about the current running app.
#
###/doc

### this:bin Usage:bbuild
# The file name of the running script, without its path
###/doc
function this:bin {
    echo "$(basename "$0")"
}

### this:bindir Usage:bbuild
# The absolute path of the directory in which the command is running
###/doc
function this:bindir {
    echo "$(abspath:path "$(dirname "$0")" )"
}
