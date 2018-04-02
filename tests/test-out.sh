#%include test.sh
#%include out.sh colours.sh

#TODO further tests required around out:break and out:dump

test_out() {
	local expect="$1"; shift

	local result="$("$@" 2>&1)"

	echo "$result"

	[[ "$result" = "$expect" ]]
}

test_defer() {
	local expect="$1"; shift

	local result="$(
	out:defer three
	echo "one"
	out:defer four
	echo "two"
	out:flush echo
	)"

	result="$(echo "$result"|xargs echo)"

	echo "$result"

	[[ "$result" = "$expect" ]]
}

test_text="Hello world"

test:require test_out "$(echo "${CGRN}${test_text}${CDEF}")" out:info "${test_text}"
test:require test_out "$(echo "${CBYEL}WARN: ${CYEL}${test_text}${CDEF}")" out:warn "${test_text}"
test:require test_out "$(echo "${CBRED}ERROR: ${CRED}${test_text}${CDEF}")" out:error "${test_text}"
test:require test_out "$(echo "${CBRED}ERROR FAIL: ${CRED}${test_text}${CDEF}")" out:fail "${test_text}"
test:require test_defer "one two three four"

test:forbid test_out "$(echo "${CBBLU}DEBUG: ${CBLU}${test_text}${CDEF}")" out:debug "${test_text}"

MODE_DEBUG=true test:require test_out "$(echo "${CBBLU}DEBUG: ${CBLU}${test_text}${CDEF}")" out:debug "${test_text}"

test:report
