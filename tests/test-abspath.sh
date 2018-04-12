#%include test.sh abspath.sh

test_path() {
    local result="$1"; shift

    local got="$(abspath:path "$@")"

    echo "$got"

    [[ "$got" = "$result" ]]
}

test_py() {
    out:info "  test abspath:path"
    time for x in {1..1000}; do
        abspath:path . >/dev/null
    done

    out:info "  test python"
    time for x in {1..1000}; do
        python -c "import os; os.path.abspath('.')"
    done
}

test:require test_path "$PWD"                       ""
test:require test_path "$PWD"                       "."
test:require test_path "$PWD"                       "./"
test:require test_path "/"                          "/one/.."
test:require test_path "/"                          "/./one/.."
test:require test_path "/"                          "/./"
test:require test_path "$PWD/dest"                  "dest"
test:require test_path "$PWD/thing/dest"            "thing/there/../dest"
test:require test_path "$(dirname "$PWD")"          ".."
test:forbid  test_path "/"                          "/.."
test:forbid  test_path "/"                          "/one/two/../../.."
test:require test_path "/first/second/branched/end" "/first/second/third/./../branched/sub/.././end"
test:require test_path "/first"                     "/first/second/third/fourth/../../../"
test:forbid  test_path "/first"                     "/first/second/third/fourth/../../../" 1
test:require test_path "/foo/aa/bar"                "/foo/aa/bar"
test:require test_path "/one/two"                   "/one/two/."
test:require test_path "/one/two/a"                 "/one/two/a"
test:require test_path "/one/two/a"                 "//one////two///a"

#out:info "Comparing performance against python version"
#test_py

test:report
