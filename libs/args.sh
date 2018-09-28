##bash-libs: args.sh @ %COMMITHASH%

#%include patterns.sh out.sh

### args Usage:bbuild
#
# An arguments handling utility.
#
###/doc

### args:get TOKEN ARGS ... Usage:bbuild
#
# Given a TOKEN, find the argument value
#
# Typically called with the parent's arguments
#
# 	args:get --key "$@"
# 	args:get -k "$@"
#
# If TOKEN is an int, returns the argument at that index (starts at 1, negative numbers count from end backwards)
#
# If TOKEN starts with two dashes ("--"), expect the value to be supplied after an equal sign
#
# 	--token=desired_value
#
# If TOKEN starts with a single dash, and is a letter or a number, expect the value to be the following token
#
# 	-t desired_value
#
# Returns 1 if could not find anything appropriate.
#
###/doc

args:get() {
    local seek="$1"; shift || :

    if [[ "$seek" =~ $PAT_num ]]; then
        local arguments=("$@")

        # Get the index starting at 1
        local n=$((seek-1))
        # but do not affect wrap-arounds
        [[ "$n" -ge 0 ]] || n=$((n+1))

        echo "${arguments[$n]}"

    elif [[ "$seek" =~ ^--.+ ]]; then
        args:get_long "$seek" "$@"

    elif [[ "$seek" =~ ^-[a-zA-Z0-9]$ ]]; then
        args:get_short "$seek" "$@"

    else
        return 1
    fi
}

args:get_short() {
    local token="$1"; shift || :
    while [[ -n "$*" ]]; do
        local item="$1"; shift || :

        if [[ "$item" = "$token" ]]; then
            echo "$1"
            return 0
        fi
    done
    return 1
}

args:get_long() {
    local token="$1"; shift || :
    local tokenpat="^$token=(.*)$"

    for item in "$@"; do
        if [[ "$item" =~ $tokenpat ]]; then
            echo "${BASH_REMATCH[1]}"
            return 0
        fi
    done
    return 1
}

### args:has TOKEN ARGS ... Usage:bbuild
#
# Determines whether TOKEN is present on its own in ARGS
#
# Typically called with the parent's arguments
#
# 	args:has thing "$@"
#
# Returns 0 on success for example
#
# 	args:has thing "one" "thing" "or" "another"
#
# Returns 1 on failure for example
#
# 	args:has thing "one thing" "or another"
#
# "one thing" is not a valid match for "thing" as a token.
#
###/doc

args:has() {
    local token="$1"; shift || :
    for item in "$@"; do
        if [[ "$token" = "$item" ]]; then
            return 0
        fi
    done
    return 1
}

### args:after TOKEN ARGS ... Usage:bbuild
#
# Return all tokens after TOKEN via the RETARR_ARGSAFTER
#
#    myargs=(one two -- three "four and" five)
# 	args:after -- "${myargs[@]}"
#
# 	for a in "${RETARR_ARGSAFTER}"; do
# 		echo "$a"
# 	done
#
# The above prints
#
# 	three
# 	four and
# 	five
#
###/doc

args:after() {
    local token="$1"; shift || :
    
    local current_token="$1"; shift || :
    while [[ "$#" -gt 0 ]] && [[ "$current_token" != "$token" ]]; do
        current_token="$1"; shift || :
    done

    RETARR_ARGSAFTER=("$@")
}

### args:use ARGNAMES ... -- ARGVALUES ... Usage:bbuild
# 
# Consume arguments into named variables. You need to use process subtitution and sourcing
#   to call the function, so that it affects the scope in your function.
#
# If not enough argument values are found, the named variable that failed to be assigned is printed as error
#
# Example:
#
#   use_settings() {
#       . <(args:use WEBHOST WEBPATH -- "$@")
#       WEBQUERY="$(echo "$*" | sed -r 's/ +/\&/g')"
#   }
#
#   use_settings example.com /path/on/server one=1 two=2
#   echo "$WEBHOST/$WEBPATH?$WEBQUERY"
#   
#   # prints
#   #
#   #   example.com/path/on/server?one=1&two=2
#
###/doc
args:use() {
    local argname arglist # TODO - consume meta args
    arglist=(:)
    for argname in "$@"; do
        [[ "$argname" != -- ]] || break
        [[ "$argname" =~ ^[0-9a-zA-Z_]+$ ]] || out:fail "Internal: Not a valid argument name '$argname'"

        arglist+=("$argname")
    done

    for argname in "${arglist[@]:1}"; do
        echo "$ARGSLIB_scope $argname=\"\${1:-}\"; shift || out:fail \"Internal : could not get '$argname'\""
    done
}


### args:use:local ARGNAMES ... -- ARGVALUES ... Usage:bbuild
# 
# Consume arguments into named variables. You need to use process subtitution and sourcing
#   to call the function, so that it affects the scope in your function.
#
# If not enough argument values are found, the named variable that failed to be assigned is printed as error
#
# Example:
#
#   person() {
#       . <(args:use:local name email -- "$@")
#
#       echo "$name <$email>"
#
#       echo "-- $* --"
#   }
#
#   person "Jo Smith" "jsmith@exam0ple.com" Some details
#   echo "[$name]"
#
#   # prints
#   #
#   #     Jo Smith <jsmith@example.com>
#   #     -- Some details --
#   #     []
###/doc
args:use:local() {
    ARGSLIB_scope=local args:use "$@"
}
