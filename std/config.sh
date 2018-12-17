#%include std/syntax-extensions.sh
#%include std/patterns.sh

##bash-libs: config.sh @ %COMMITHASH%

### config.sh Usage:bbuild
# Read configuration from various locations.
#
# Declare multiple config file locations, in increasing order of authority, and read values from all, keeping only the most authoritative value.
#
###/doc

### config:declare Usage:bbuild
#
# Declare a set of config files, more general file first, then read values from each file in turn.
#
# Example config contents and variable declaration
#
#   # Example configuration file contents
#
#   echo -e "first=1\\nsecond=2\\nthird=3" > /etc/test.conf
#   echo -e "second=two\\nthird=" > ./test.conf
#
#   # Declare the order to read values from, then read values
#
#   config:declare confs /etc/test.conf ./test.conf
#
###/doc

$%function config:declare(*configname) {
    configname=("$@")
}

$%function config:_read_value(key file) {
    [[ "$key" =~ $PAT_cvar ]] || out:fail "Invalid config key '$key' -- must match '$PAT_cvar'"
    grep -oP "(?<=$key=).*" "$file"
}

$%function config:_has_key(key file) {
    config:_read_value "$key" "$file" >/dev/null
}

$%function config:_foreach_read(*configname key) {
    local cfile value res
    res=1

    for cfile in "${configname[@]}"; do
        if [[ -e "$cfile" ]]; then
            if config:_has_key "$key" "$cfile"; then
                value="$(config:_read_value "$key" "$cfile")"
                res=0
            fi
        fi
    done

    echo "${value:-}"
    return "$res"
}

### config:read CONFIG KEY Uage:bbuild
#
# If an earlier file specifies a value, and a later file doesn't, the earlier file's value is used
#
# If a later file specifies a value empty, it overrides an earlier file's non-empty definition.
#
# Example, with the config files above
#
#   config:read confs first
#   # --> 1
#
#   config:read confs second
#   # --> "two"
#
#   config:read confs third
#   # --> (empty string)
#
#   config:read confs nonexistent
#   # ------> ERROR
#
###/doc

$%function config:read(configname key ?default) {
    local value res
    res=0
    value="$(config:_foreach_read "$configname" "$key")" || res="$?"

    if [[ "$res" != 0 ]] && [[ -z "$default" ]]; then
        return 1
    elif [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

### config:load NAMESPACE Usage:bbuild
#
# Use config:load NAMESPACE to load all values into a global bash namespace
#
# Example, with the config files above
#
#   config:load CONFSPACE
#   echo "CONFSPACE_second"
#   # --> "two"
#
###/doc

$%function config:load(namespace) {
    local cfile value key keys

    declare -n configname
    configname="$namespace"


    for cfile in "${configname[@]}"; do
        if [[ -e "$cfile" ]]; then
            keys=($(grep -oP '^[a-zA-Z0-9_]+(?==)' "$cfile"))
            for key in "${keys[@]}"; do
                if config:_has_key "$key" "$cfile"; then
                    value="$(config:_read_value "$key" "$cfile")" || continue
                    . <(echo "${namespace}_${key}=\"$(echo "$value"|sed 's/"/\"/g')\"")
                fi
            done
        fi
    done
}
