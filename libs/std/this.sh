#%include std/abspath.sh

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
    if [[ -n "${BBRUN_SCRIPT:-}" ]]; then
        basename "$BBRUN_SCRIPT"
    else
        basename "$0"
    fi
}

### this:bindir Usage:bbuild
# The absolute path of the directory in which the command is running
###/doc
function this:bindir {
    if [[ -n "${BBRUN_SCRIPT:-}" ]]; then
        dirname "$BBRUN_SCRIPT"
    else
        abspath:path "$(dirname "$0")"
    fi
}
