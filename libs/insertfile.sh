##bash-libs: insertfile.sh @ %COMMITHASH%

### Insert file contents Usage:bbuild
# 
# insertfile LINE DESTFILE SOURCEFILE
#
# Inserts the contents of SOURCEFILE into DESTFILE after line LINENUM
#
# When LINENUM is 0, inserts the contents before any of the lines of the file.
#
# Contrary to includefile, insertfil will always insert the file, even if it
# has done so previously.
#
###/doc

#%bbtags w:deprecated w:use_insertfile2

function insertfile {
    local line="$1"
    local destfile="$2"
    local sourcefile="$3"

    insertfile:checkargs "$@" || return 1

    local lcount="$(egrep ^ -c "$destfile")"

    if [[ "$1" -le 0 ]]; then
        insertfile:sedinsert "$destfile" "$sourcefile"

    elif [[ "$1" -gt $lcount ]]; then
        cat "$sourcefile" >> "$destfile"

    else
        insertfile:sedappend "$@"
    fi
}

function insertfile:sedappend {
    local line="$1"
    local destfile="$2"
    local sourcefile="$3"

    sed "$line r $sourcefile" -i "$destfile"
}

function insertfile:sedinsert {
    local destfile="$1"
    local sourcefile="$2"

    sed "1 {
        h
        r $sourcefile
        g
        N
    }" -i "$destfile"
}

function insertfile:checkargs {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then echo "Invalid line number"; return 1 ; fi
    if [[ ! -f "$2" ]]; then echo "Not a file $2" >&2; return 1; fi
    if [[ ! -f "$3" ]]; then echo "Not a file $3" >&2; return 1; fi
}
