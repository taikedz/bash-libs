#%include std/version.sh
#%include std/test.sh

test_gt() {
    if version:gt "$1" "$2"; then
        return 0
    else
        return 1
    fi
}

test_next() {
    local nextv="$(version:next "$1" "$2")"

    [[ "$nextv" = "$3" ]]
}

test:require test_gt 3.2.1 3.2.0
test:require test_gt 3.2.1 3.1.1
test:require test_gt 3.2.1 2.2.1

test:forbid test_gt 3.2.1 3.2.1
test:forbid test_gt 3.2.0 3.2.1
test:forbid test_gt 3.1.1 3.2.1
test:forbid test_gt 2.2.1 3.2.1

test:forbid test_gt a 3.2.1
test:forbid test_gt 3.2.1 b

test:require test_next patch 3.2.1 3.2.2
test:require test_next minor 3.2.1 3.3.0
test:require test_next major 3.2.1 4.0.0

test:report
