#%include std/test.sh
#%include std/includefile2.sh

testdir=tmp-tests

mkdir -p "$testdir"

echo "#%include file2" > "$testdir"/file1
echo "-- separator ----------" >> "$testdir"/file1
echo "#%include file2" >> "$testdir"/file1
echo "This is file2"> "$testdir"/file2

once_only() {
    [[ $( grep -c "This is file2" "$testdir/outfile" ) = 1 ]]
}

INCLUDEFILE_paths="$testdir" INCLUDEFILE_token='#%include' includefile:process "$testdir"/file1 > "$testdir/outfile"

test:require grep -q "This is file2" "$testdir/outfile"
test:require once_only

rm "$testdir/file1" "$testdir/file2" "$testdir/outfile"

test:report
