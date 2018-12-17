#!/usr/bin/env bash

#%include std/hsum.sh
#%include std/test.sh

testout() {
    local base="$1"; shift
    local expect="$1"; shift

    shift

    echo "$*"|sed -r 's/\s+/\n/g' | test:output "$expect" hsum:sum "$base"
}

test:require testout 1000 "3.0KB" - "1K 2K"
test:require testout 1000 "3.0KB" - "1000 2K"

test:require testout 1024 "3.0KB" - "1K 2K"
test:require testout 1024 "4.1MB" - "1K 4M"

test:require testout 1024 "2.1000KB" - "1000 2K"
test:require testout 1024 "4.900MB" - "900K 4M"

test:require testout 1000 "3.0KB" - "1.5K 1.5K"
test:require testout 1000 "8.3MB" - "1.5K 1.5K 5M 3M"

test:report
