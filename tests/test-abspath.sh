#%include test.sh abspath.sh

test_path() {
	local result="$1"; shift
	local routine="$1"; shift

	local got="$(abspath:simple "$@")"

	echo "$got"

	[[ "$got" = "$result" ]]
}

for abspath_fun in abspath:simple abspath:python; do
	test:require test_path "$PWD/dest" "$abspath_fun" "dest"
	test:require test_path "$PWD/thing/dest" "$abspath_fun" "thing/there/../dest"
	test:require test_path "$(dirname "$PWD")" "$abspath_fun" ".."
	test:require test_path "/" "$abspath_fun" "/.."
	test:require test_path "/foo/aa/bar" "$abspath_fun" "/foo/aa/bar"
	echo '======='
done

test:report
