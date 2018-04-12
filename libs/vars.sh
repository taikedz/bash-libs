##bash-libs: vars.sh @ %COMMITHASH%

### Vars library Usage:bbuild
#
# Functions for checking variables
#
###/doc

### vars:require VARNAME ... Usage:bbuild
#
# Check a list of environment variables such that none are non-empty.
#
# If variables are empty/not set, the name is echoed.
#
# Returns the number of missing variables.
#
#    myvarA=one
#    myvarB=
#    myvarC=three
#
#    missing="$(vars:require myvarA myvarB myvarC)"
#
#    if [[ -n "$missing" ]]; then
#        out:fail "Variables were not set : [$missing]"
#    fi
#
###/doc

vars:require() {
    local missing=(:)

    for varname in "$@"; do
        echo "[[ -n "\$$varname" ]]" | bash || {
            missing[${#missing[@]}]="$varname"
        }
    done

    missing=("${missing[@]:1}")

    echo "${missing[*]}"
    return "${#missing[@]}"
}
