#%include std/test.sh
#%include std/this.sh

t_source="/tmp/testing-source.sh"
t_dest="/tmp/testing-dest.sh"


removescripts() {
    local s
    for s in "$@"; do
        [[ ! -f "$s" ]] || rm "$s"
    done
}

equals() {
    local desired="$1"; shift
    local output="$("$t_dest" "$@")"

    echo "$output"

    [[ "$desired" = "$output" ]]
}

trap removescripts exit

echo -e '#%include std/this.sh\n\n"$@"\n' > "$t_source"

bbuild "$t_source" "$t_dest" || exit

test:require equals testing-dest.sh this:bin
test:require equals /tmp this:bindir

# Simulate use of bbrun
export BBRUN_SCRIPT=/var/stuff

test:require equals stuff this:bin
test:require equals /var this:bindir


test:report
