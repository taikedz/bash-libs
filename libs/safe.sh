##bash-libs: safe.sh @ %COMMITHASH%

### Safe mode Usage:bbuild
#
# Set global safe mode options
#
# * Script bails if a statement or command returns non-zero status
#   * except when in a conditional statement
# * Accessing a variable that is not set is an error, causing non-zero status of the operation
# * Prevents globs
# * If a component of a pipe fails, the entire pipe statement returns non-zero
#
# Splitting over spaces
# ---------------------
#
# You can also switch space splitting on or off (normal bash default is 'on')
#
# Given a function `foo()` that returns multiple lines, which may each have spaces in them, use safe splitting to return each item into an array as its own item, without splitting over spaces.
#
#   safe:space-split off
#   mylist=(foo)
#   safe:space-split on
#
# Having space splitting on causes statements like `echo "$*"` to print each argument on its own line.
#
# Globs
# -------
#
# In safe mode, glob expansion like `ls .config/*` is turned off by default.
#
# You can turn glob expansion on and off with `safe:glob on` or `safe:glob off`
#
###/doc

set -eufo pipefail

safe:space-split() {
    case "$1" in
    off)
        export IFS=$'\t\n'
        ;;
    on)
        export IFS=$' \t\n'
        ;;
    *)
        out:fail "API error: bad use of safe:split - must be 'on' or 'off' not '$1'"
        ;;
    esac
}

safe:glob() {
    case "$1" in
    off)
        set -f
        ;;
    on)
        set +f
        ;;
    *)
        out:fail "API error: bad use of safe:glob - must be 'on' or 'off' not '$1'"
        ;;
    esac
}
