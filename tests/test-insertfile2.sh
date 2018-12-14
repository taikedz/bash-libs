#%include std/test.sh
#%include std/insertfile2.sh

testdir=tmp-tests

mkdir -p "$testdir"

echo -e "1 one\n1 two\n1 three" > "$testdir/file1"
echo "target-line" > "$testdir/file2"

test_insert() {
    local line="$1"; shift
    local check="$1"; shift

    [[ $(insertfile $line "$testdir/file1" "$testdir/file2" | grep "target-line" -n | cut -d: -f1) = $check ]]
}

test:require test_insert 0 1
test:forbid test_insert 0 2
test:require test_insert 1 2
test:forbid test_insert 1 1
test:forbid test_insert 1 3

rm "$testdir/file1" "$testdir/file2"

test:report
