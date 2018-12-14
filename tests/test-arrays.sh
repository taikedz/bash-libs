#!/bin/bash

#%include std/arrays.sh
#%include std/test.sh

AR_main=(one two "three four" five)

serial_data() {
    arrays:serialize "${AR_main[@]}"
}

test_array_extract() {
    # TAE INDEX EXPECT ITEMS ...

    local index expected serialized got
    index="$1"; shift
    expected="$1"; shift

    serialized="$(serial_data)" # Call a function that returns serialized data

    got="$(arrays:get $index "${serialized[@]}")"

    echo "$got"
    [[ "$expected" = "$got" ]]
}

test_require_idem() {
    local item_s item_d

    item_s="$(arrays:serialize "$1")"
    item_d="$(arrays:get "$item_s")"

    echo "[$1] ==> [$item_s] ==> [$item_d]"
    [[ "$item_d" = "$1" ]]
}

test_count() {
    local sdata i x
    sdata="$(serial_data)"
    sdata=($sdata) # Needed for th ${#[@]} notation below
    i=0

    for x in ${sdata[@]} ; do
        i=$((i+1))
    done

    echo "i[$i] = ${#sdata[@]}"
    [[ ${#sdata[@]} = $i ]]
}

### Test the alternate mode
#ARRAYSLIB_mode=escapes

test:require test_array_extract 0 one
test:require test_array_extract 2 "three four"
test:require test_count

test:require test_require_idem "hi"
test:require test_require_idem "you there"
test:require test_require_idem ""
test:require test_require_idem "$(echo -e "\t")"
test:require test_require_idem "$(echo -e "\n")"
test:require test_require_idem "$(echo -e "\r")"
test:require test_require_idem "$(echo -e "\r\n")"
test:require test_require_idem "$(echo -e "a\tb\n\r\n--")"

test:require arrays:get 1 $(arrays:serialize "${AR_main[@]}")
test:forbid arrays:get 10 $(arrays:serialize "${AR_main[@]}")
test:forbid arrays:get -1 $(arrays:serialize "${AR_main[@]}")

test:report
