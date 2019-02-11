##bash-libs: readkv.sh @ %COMMITHASH%

### Key Value Pair Reader Usage:bbuild
#
# Read a value given the key, from a specified file
#
###/doc

### readkv KEY FILE [DEFAULT] Usage:bbuild
#
# The KEY is the key in the file. A key is identified as starting at the beginning of a line, and ending at the first '=' character
#
# The value starts immediately after the first '=' character.
#
# If no value is found, the DEFAULT value is returned, or an empty string
#
###/doc

function readkv {
    local thedefault thekey thefile
    thekey="$1" ; shift
    thefile="$1"; shift

    if [[ -n "${1:-}" ]]; then
        thedefault="$1"; shift || :
    fi

    local res="$(readkv:meaningful_data "$thefile"|grep -E "^$thekey"'\s*='|sed -r "s/^$thekey"'\s*=\s*//')"
    if [[ -z "$res" ]]; then
        echo "${thedefault:-}"
    else
        echo "$res"
    fi
}

### readkv:require KEY FILE Usage:bbuild
#
# Like readkv, but causes a failure if the file does not exist.
#
###/doc

function readkv:require {
    if [[ -z "${2:-}" ]]; then
        out:fail "No file specified to read [$*]"
    fi

    if [[ ! -f "$2" ]] ; then
        out:fail "No such file $2 !"
    fi

    if ! head -n 1 "$2" > /dev/null; then
        out:fail "Could not read $2"
    fi
    readkv "$@"
}

### readkv:meaningful_data FILE Usage:bbuild
# Dump the file contents, stripping meaningless data (empty lines and comment lines)
###/doc
readkv:meaningful_data() {
    grep -v -P '^\s*(#.*)?$' "$1"
}
