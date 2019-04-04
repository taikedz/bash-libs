#%include std/out.sh
#%include std/safe.sh

##bash-libs: test.sh @ %COMMITHASH%

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
# 	test:report
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
    TEST_testfailurecount=$((TEST_testfailurecount+1))
}

### test:require COMMAND ARGS ... Usage:bbuild
#
# Runs the command with arguments; if the command returns 0 then success
#
# If the command returns non-zero, then a failure is reported, and the
#  command's output is printed
#
###/doc

test:require() {
    local result=:
    local status=0
    result="$("$@")" || status="$?"
    if [[ "$status" = 0 ]] ; then
        test:ok "REQUIRE: [ $* ]"
        if [[ "${ECHO_OK:-}" = true ]]; then
            echo -e "<--\n$result\n-->"
        fi
    else
        test:fail "REQUIRE: [ $* ]"
        echo -e "<<< ---\n$result\n--- >>>"
    fi
}

### test:require COMMAND ARGS ... Usage:bbuild
#
# Runs the command with arguments; if the command returns 0 then a failure
#  is reported, and the command's output is printed
#
# If the command returns non-zero, then success
#
###/doc

test:forbid() {
    local result=:
    local status=0
    result="$("$@")" || status="$?"
    if [[ "$status" = 0 ]] ; then
        test:fail "FORBID : [ $* ]"
        echo "$res => $result" | sed 's/^/  /'
    else
        test:ok "FORBID : [ $* ]"
    fi
}

### test:report Usage:bbuild
#
# Report the number of tests ran, and failed
#
##/doc

test:report() {
    local reportcmd=out:info
    if [[ "$TEST_testsran" -lt 1 ]]; then
        reportcmd=out:warn
        TEST_testfailurecount=1

    elif [[ "$TEST_testfailurecount" -gt 0 ]]; then
        reportcmd=out:error
    fi

    "$reportcmd" "[$(basename "$0")] --- Ran $TEST_testsran tests with $TEST_testfailurecount failures"

    return "$TEST_testfailurecount"
}

### test:output EXPECTED COMMAND ... Usage:bbuild
# Test a command's output for expected content.
#
# Runs COMMAND ... and captures output. If the output matches the EXPECTED value, returns 0
# else returns 1
#
# Always prints the output ; combine with test:require and test:forbid
#
###/doc

test:output() {
    local expect="$1"; shift
    local res=0
    local output

    output="$("$@")" || :

    echo "$output"
    [[ "$expect" = "$output" ]]
}

### test:set-unsafe Usage:bbuild
# By default, test.sh applies safe mode with safe.sh.
#
# Call test:set-unsafe to assume running outside of safe mode.
###/doc
test:set-unsafe() {
    set +euo pipefail
    safe:glob on
}
