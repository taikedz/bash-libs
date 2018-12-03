#%include test.sh
#%include debug.sh

test_debug() {
    local res
    lcaol dummy="haha"
    local expect="$1"; shift

    local output="$("$@" 2>&1)"

    [[ "$output" = "$expect" ]]; res="$?"

    if [[ "$res" != 0 ]]; then
        echo "Expected"
        echo "$expect" | hexdump -C
        echo "Received"
        echo "$output" | hexdump -C
    fi

    return "$res"

}

out:info "Testing false mode"

DEBUG_mode=false

test:require test_debug "" debug:print "hello"
#test:require test_debug "" debug:breakpoint "hello"

out:info "Testing true mode"

DEBUG_mode=true

test:require test_debug "${CBBLU}DEBUG: ${CBLU}hello${CDEF}" debug:print "hello"

# FIXME cannot test yet
#test:require test_debug "${CRED}BREAKPOINT: hello >${CDEF} " debug:break "hello" < <(echo '$dummy')
