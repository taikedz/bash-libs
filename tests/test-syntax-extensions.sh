#!/bin/bash

#%include std/test.sh
#%include std/syntax-extensions.sh

$%function callme(myvar) {
    echo "${myvar:-}"
}

callvar() {
    local expect="$*"
    local result="$(callme "$expect")"

    [[ "$result" = "$expect" ]]
}

test:require callvar "simple string"

test:report
