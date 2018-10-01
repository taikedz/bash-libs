### Data maps Usage:bbuild
#
# A data map libarary - associate a value to a key under a parent block
#
# Whereas in some languages you would be able to do
#
#   thing["key"] = "my value"
#   print(thing["key"])
#
# in bash you use datamaps.sh to do
#
#   map:add thing key "my value"
#   echo "$(map:get thing key)"
#
###/doc

MAPKEYLIB_identifier="MAPKEYLIB__"

map:add() {
    local map_key_pair
    map_key_pair="$(map:key_pair_name "$1" "$2")"
    shift 2

    . <(echo "$map_key_pair=\"$*\"")
}

map:get() {
    local map_key_pair
    map_key_pair="$(map:key_pair_name "$1" "$2")"
    shift 2

    . <(echo "echo \"\$$map_key_pair\"")
}

map:del() {
    local map_key_pair
    map_key_pair="$(map:key_pair_name "$1" "$2")"
    shift 2

    . <(echo "unset $map_key_pair")
}

map:keys() {
}

map:values() {
}

map:pairs() {
}

map:_hash() {
    echo "$*" |md5sum |cut -f1 -d' '
}

map:key_pair_name() {
    local mapnamehash keynamehash
    mapnamehash="$(map:_hash "$1")"; shift
    keynamehash="$(map:_hash "$1")"; shift
    echo "$MAPKEYLIB_identifier${mapnamehash}_${keynamehash}"
}
