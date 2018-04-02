#%include test.sh ensureline.sh

testdir="tmp-tests"
mkdir -p "$testdir"

rline="replacement line"

init_test_file() {
	tf="$testdir/targetfile"

	echo -e "One\nTwo\n#Three\nFour" > "$tf"
}

ecount() {
	local pattern="$1"; shift
	local count="$1"; shift

	ensureline "$tf" "$pattern" "$rline"
	cat "$tf"
	[[ $(grep "$rline" "$tf" -c) = $count ]]
}

islast() {
	ecount "$1" 1 && [[ $(tail -n 1 "$tf") = "$rline" ]]
}

init_test_file
test:require ecount "One" 1

init_test_file
test:require ecount "^#T.+" 1

init_test_file
test:require ecount "^T.+" 1

init_test_file
test:require ecount "#?T.+" 2

init_test_file
test:require ecount "line not here" 1

init_test_file
test:require islast "ne"

rm "$tf"

test:report
