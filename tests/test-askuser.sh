#%include std/test.sh
#%include std/askuser.sh

test_input() {
    local input="$1"; shift

    echo "$input" | "$@" 
}

test_input_response() {
    local expect="$1"; shift

    local response="$(test_input "$@" "choice" "$choice_list" 2>/dev/null)"

    echo "$response"

    [[ "$expect" = "$response" ]]
}

test_input_return() {
    local expect_res="$1"; shift

    test_input "$@" "choice" "$choice_list" 2>/dev/null
    local res="$?"

    [[ "$res" = "$expect_res" ]]
}

choice_1="Alice Alisson"
choice_2="Bob Robertson"
choice_3="Carol Karlsson"
choice_4="David Davidson"
choice_list="$(echo -e "$choice_1\n$choice_2\n$choice_3\n$choice_4")"

test:require test_input y    askuser:confirm question
test:forbid  test_input n    askuser:confirm question 
test:forbid  test_input no   askuser:confirm question 
test:forbid  test_input ""   askuser:confirm question 
test:forbid  test_input what askuser:confirm question 
test:forbid  test_input ye   askuser:confirm question 

test:require test_input_response hello hello  askuser:ask prompt
test:forbid  test_input_response hellos hello askuser:ask prompt

test:require test_input_response hello hello  askuser:password prompt
test:forbid  test_input_response hellos hello askuser:password prompt

echo -e "Choice list:\n$choice_list"

test:require test_input_response "$choice_1" 1 askuser:choose
test:require test_input_response "$choice_3" 3 askuser:choose
test:forbid test_input_return 0 "" askuser:choose

test:require test_input_response "$choice_1" 1 askuser:choose_multi
test:require test_input_response "$(echo -e "$choice_1\n$choice_2\n$choice_3")" 1,3 askuser:choose_multi


test:report
