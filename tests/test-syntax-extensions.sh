#!/bin/bash

#%include test.sh
#%include args.sh

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
