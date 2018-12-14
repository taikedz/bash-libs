#%include std/syntax-extensions.sh
#%include std/patterns.sh

##bash-libs: config.sh @ %COMMITHASH%

### config.sh Usage:bbuild
# Read configuration from various locations.
###/doc

### config:declare Usage:bbuild
#
# Declare a set of config files, more general file first, then read values from each file in turn.
#
# Example config contents and variable declaration
#
#   echo -e "first=1\\nsecond=2\\nthird=3" > /etc/test.conf
#   echo -e "second=two\\nthird=" > ./test.conf
#
#   config:declare /etc/test.conf ./test.conf
#
###/doc

config:declare() {
    CONFIG_files=("$@")
}

$%function config:_read_value(key file) {
    [[ "$key" =~ $PAT_cvar ]] || out:fail "Invalid config key '$key' -- must match '$PAT_cvar'"
    grep -oP "(?<=$key=).*" "$file"
}

$%function config:_has_key(key file) {
    config:_read_value "$key" "$file" >/dev/null
}

$%function config:_foreach_read(key) {
    local cfile value res
    res=1

    for cfile in "${CONFIG_files[@]}"; do
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

### config:read KEY Uage:bbuild
#
# If an earlier file specifies a value, and a later file doesn't, the earlier file's value is used
#
# If a later file specifies a value empty, it overrides an earlier file's non-empty definition.
#
# Example, with the config files above
#
#   config:read first
#   # --> 1
#
#   config:read second
#   # --> "two"
#
#   config:read third
#   # --> (empty string)
#
#   config:read nonexistent
#   # ------> ERROR
#
###/doc

$%function config:read(key ?default) {
    local value
    value="$(config:_foreach_read "$key")"
    if [[ -z "$value" ]]; then
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
#   config:load MYSCRIPT
#   echo "$MYSCRIPT_second"
#   # --> "two"
#
###/doc

$%function config:load(namespace) {
    local cfile value key keys

    for cfile in "${CONFIG_files[@]}"; do
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
