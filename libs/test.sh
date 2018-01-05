#%include out.sh

### Tests library Usage:bbuild
#
# Library for testing functions
#
# Example:
#
# 	isgreater() {
# 		echo "Checking $1 > $2"
# 		[[ "$1" -gt "$2" ]]
# 	}
#
# 	test:require isgreater 5 3
# 	test:forbid isgreater 3 5
# 	test:forbid isgreater 5 5
#
###/doc

TEST_testfailurecount=0
TEST_testsran=0

test:ok() {
	echo -e "${CBGRN} OK ${CDEF} $*"
	TEST_testsran=$((TEST_testsran+1))
}

test:fail() {
	echo -e "${CBRED}FAIL${CDEF} $*"
	TEST_testsran=$((TEST_testsran+1))
	TEST_testfailurecount=$((TESTS_testfailurecount+1))
}

### test:require COMMAND ARGS ... Usage:bbuild
#
# Runs the command with arguments; if the command returns 0 then success
#
# If the command returns non-zero, then a failure is reported
#
###/doc

test:require() {
	local result=:
	result="$("$@")"
	if [[ "$?" = 0 ]] ; then
		test:ok "REQUIRE: $*"
	else
		test:fail "REQUIRE: $*"
		echo "$result" | sed 's/^/  /'
	fi
}

### test:require COMMAND ARGS ... Usage:bbuild
#
# Runs the command with arguments; if the command returns 0 then a failure is reported
#
# If the command returns non-zero, then success
#
###/doc

test:forbid() {
	local result=:
	result="$("$@")"
	if [[ "$?" = 0 ]] ; then
		test:fail "FORBID : $*"
		echo "$res => $result" | sed 's/^/  /'
	else
		test:ok "FORBID : $*"
	fi
}

### test:report Usage:bbuild
#
# Report the number of tests ran, and failed
#
##/doc

test:report() {
	local reportcmd=out:info
	if [[ "$TEST_testfailurecount" -gt 0 ]]; then
		reportcmd=out:warn

	elif [[ "$TEST_testfailurecount" -ge $((TEST_testsran / 2)) ]]; then
		reportcmd=out:fail
		[[ "$TEST_testsran" -gt 0 ]] || TEST_testfailurecount=1
	fi

	( # Don't bail on out:fail
	"$reportcmd" "--- Ran $TEST_testsran tests with $TEST_testfailurecount failures"
	)

	return "$TEST_testfailurecount"
}
