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
# Using bash's defaults, array assignments split over any whitespace.
#
# Using safe mode, arrays only split over newlines, not over spaces.
#
# Return to default unsafe behaviour using `safe:space-split on`
#
# Reactivate safe recommendation using `safe:space-split off`
#
# Globs
# -------
#
# In safe mode, glob expansion like `ls .config/*` is turned off by default.
#
# You can turn glob expansion on with `safe:glob on`, and off with `safe:glob off`
#
###/doc

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

set -eufo pipefail
safe:space-split off
