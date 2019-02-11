#%include std/searchpaths.sh
#%include std/syntax-extensions.sh

##bash-libs: includefile2.sh @ %COMMITHASH%

### File Inclusion Usage:bbuild
# Library for including (once) or inserting (any time called) external files ontents
# based on developer-defined tokens
###/doc

includefile:reset_tracker() {
    INCLUDEFILE_tracker=""
}

### includefile:process TARGET Usage:bbuild
# Perform inclusions on stated target file
#
# Writes fully included result to stdout
#
# set INCLUDEFILE_token string to define the token which, at the begining of a line
#  declares a single file to include
# set INCLUDEFILE_paths colon-delimited string to a search path from which to find scripts to source
###/doc
includefile:process() {
    local target
    local workfile
    local dumpfile
    target="$1"; shift
    workfile="$(mktemp ./._include-XXXX)"
    dumpfile="$(mktemp ./._include-d-XXXX)"

    trap "includefile:cleanup" SIGINT EXIT

    : ${INCLUDEFILE_paths=./}
    : ${INCLUDEFILE_token=@include}

    includefile:reset_tracker
    
    cat "$target" > "$workfile"
    
    while includefile:_has_inclusion_line "$workfile"; do
        includefile:_process_first_inclusion "$workfile" > "$dumpfile" || return 1
        cat "$dumpfile" > "$workfile"
    done

    cat "$workfile"
}

### includefile:_process_first_inclusion TARGET Usage:internal
# Find the first onclusion line, and include its target in the output
#
# returns 0 on successful inclusion
# returns 1 on issues with inclusion
###/doc
includefile:_process_first_inclusion() {
    local fd_target="$1"; shift
    local target="$(mktemp)"
    cat "$fd_target" > "$target"

    local pos=$(includefile:_get_inclusion_line_pos "$target")
    local inctoken="$(includefile:_get_inclusion_line_string "$target")"

    head -n $((pos - 1)) "$target"
    includefile:_cat_once "$inctoken" || return 1
    tail -n +$((pos + 1)) "$target"

    rm "$target"

    return 0
}

includefile:_get_inclusion_line_pos() {
    local targetfile="$1"; shift

    grep -nP "^$INCLUDEFILE_token" "$targetfile" | head -n 1 | cut -d: -f1
}

includefile:_get_inclusion_line_string() {
    local targetfile="$1"; shift

    grep -P "^$INCLUDEFILE_token" "$targetfile" | head -n 1 | sed -r -e "s^$INCLUDEFILE_token" -e 's/^\s+|\s+$//g'
}

includefile:_has_inclusion_line() {
    local targetfile="$1"; shift

    grep -qP "^$INCLUDEFILE_token" "$targetfile"
}

$%function includefile:_cat_once(item) {
    local fullpath
    local b64t

    [[ -n "$item" ]] || return 1

    fullpath="$(searchpaths:file_from "$INCLUDEFILE_paths" "$item")"
    if [[ -z "$fullpath" ]]; then
        INCLUDEFILE_failed="$item"
        return 1
    fi
    
    b64t=";$(echo "$fullpath" | base64 -w 0);"
    if [[  "$INCLUDEFILE_tracker" =~ "$b64t" ]]; then
        return
    fi

    export INCLUDEFILE_tracker="$INCLUDEFILE_tracker $b64t"
    cat "$fullpath"
}

includefile:cleanup() {
    rm ./._include-*
}
