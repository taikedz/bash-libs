#%include test.sh args.sh

test_args() {
    local result="$1"; shift

    local got="$(args:get "$@")"
    echo "$got"

    [[ "$got" = "$result" ]]
}

test_bool() {
    local result="$1"; shift
    args:has "$@"
    local res="$?"

    echo "$res"
    [[ "$res" = "$result" ]]
}

arguments=(-m hello --message="this is a long message" -t)

test:require test_args hello -m "${arguments[@]}"
test:require test_args "this is a long message" --message "${arguments[@]}"
test:require test_bool 0 -t "${arguments[@]}"
test:forbid test_bool 0 -x "${arguments[@]}"

test:report
