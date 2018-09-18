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

    . <(echo "echo \$$map_key_pair")
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

map:_hash() {
    echo "$*" |md5sum |cut -f1 -d' '
}

map:key_pair_name() {
    local mapnamehash keynamehash
    mapnamehash="$(map:_hash "$1")"; shift
    keynamehash="$(map:_hash "$1")"; shift
    echo "$MAPKEYLIB_identifier${mapnamehash}_${keynamehash}"
}
