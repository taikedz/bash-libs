#!/us/bin/env bash

#TODO further tests required around out:break and out:dump

set -u
#%include debug.sh
#%include test.sh

test_out() {
    local expect="$1"; shift

    local result="$("$@" 2>&1)"

    echo "$result"

    [[ "$result" = "$expect" ]]
}

test_text="Debug text"

test:forbid test_out "$(echo "${CBBLU}DEBUG: ${CBLU}${test_text}${CDEF}")" debug:print "${test_text}"

export DEBUG_mode=true

test:require test_out "$(echo "${CBBLU}DEBUG: ${CBLU}${test_text}${CDEF}")" debug:print "${test_text}"

test:report
