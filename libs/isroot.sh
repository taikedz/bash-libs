#%include out.sh

##bash-libs: isroot.sh @ %COMMITHASH%

### isroot Usage:bbuild
# Test for root access
#
# If using cygwin, user is always root.
###/doc

function isroot {
    [[ "$UID" = 0 ]] || isroot:cygwin
}

### isroot:cygwin Usage:bbuild
# Returns whether running under cygwin.
#
# Typically a user under cygwin is root, except when they're not
#
# This utility exists as a reminder to check for cygwin.
###/doc

function isroot:cygwin {
    uname -o | grep -i cygwin -q
}

### isroot:require MESSAGE Usage:bbuild
# Require root. If script is not running as root,
# print message and exit
###/doc
function isroot:require {
    isroot || out:fail "$*"
}
