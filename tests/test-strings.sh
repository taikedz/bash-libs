#%include test.sh
#%include strings.sh

test_join() {
	local result="$1"; shift
	local joined="$(strings:join "$@")"
	
	echo "$joined"

	[[ "$result" = "$joined" ]] && return 0
	return 1
}

test_split() {
	local idx="$1"; shift
	local match="$1"; shift
	
	strings:split "$@"

	echo "${STRINGS_ARR_SPLITS[$idx]}"

	[[ "${STRINGS_ARR_SPLITS[$idx]}" = "$match" ]]
}

test:require test_join "a+b+c" + a b c
test:require test_join "" "" ""
test:require test_join "thing and sung" " and " thing sung
test:forbid test_join "+a+b" + a b

test:require test_split 1 "b c" / "a/b c/d"

test:report
