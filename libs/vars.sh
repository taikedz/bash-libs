##bash-libs: vars.sh @ %COMMITHASH%

### Vars library Usage:bbuild
#
# Functions for checking variables
#
###/doc

### vars:require RETURNVAR VARNAMES ... Usage:bbuild
#
# Check a list of environment variables such that none are non-empty.
#
# If variables are empty/not set, the name is added to the return holder variable.
#
# Example:
#
#    myvarA=one
#    myvarB=
#    myvarC=three
#
#    if ! vars:require missing_vars myvarA myvarB myvarC ; then
#        echo "The following variables are not set: $missing_vars"
#    fi
#
###/doc

vars:require() {
    local missing_var="${1:-}" ; shift || out:fail "Internal error: no aruments passed for var check"
    local res=0

    for varname in "$@"; do
        . <(echo "[[ -n \"\${$varname:-}\" ]]") || {
            . <(echo "$missing_var=\"\${$missing_var:-} $varname\"")
            res=1
        }
    done

    return "$res"
}
