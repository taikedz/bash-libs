#%include test.sh includefile.sh

testdir=tmp-tests

mkdir -p "$testdir"

echo "#%include file2" > "$testdir"/file1
echo "This is file2"> "$testdir"/file2

includefile:inittemp "$testdir/file1"
includefile:include "$testdir"/file1 '#%include' "$testdir"

test:require grep -q "This is file2" "$testdir"/file1

rm "$testdir/file1" "$testdir/file2"

test:report
