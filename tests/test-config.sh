#!/usr/bin/env bash

#%include std/config.sh
#%include std/test.sh

tfile() {
    declare -n tfile="$1"; shift
    tfile="$(mktemp)"

    echo -e "$*" > "$tfile"
}

confmatch() {
    local expected="$1"; shift
    
    local confval
    confval="$("$@")"

    [[ "$confval" = "$expected" ]]; res="$?"

    echo "$confval"
    return "$res"
}

valmatch() {
    echo "$2"
    [[ "$1" = "$2" ]]
}

tfile config_main "first=alpha\nsecond=beta\nthird=gamma"
tfile config_sub "second=two\nthird="

config:declare myconfs "$config_main" "$config_sub"
config:load myconfs

test:require confmatch "alpha" config:read myconfs first
test:require confmatch "two" config:read myconfs second
test:require confmatch "" config:read myconfs third

test:forbid  config:read myconfs fourth
test:require confmatch "defval" config:read myconfs fourth "defval"

test:forbid  config:read myconfs_bad first

test:report
