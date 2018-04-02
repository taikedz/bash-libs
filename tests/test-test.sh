#%include test.sh

# This is stupid....

expect_ok() {
	"$@" | grep ' OK '
}

expect_fail() {
	"$@" | grep 'FAIL'
}

test:require true
test:forbid false

test:require expect_ok test:require true
test:require expect_fail test:require false
test:require expect_ok test:forbid false
test:require expect_fail test:forbid true

test:report
