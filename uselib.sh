#!/usr/bin/env bash

export HERE="$(cd "$(dirname "$0")"; pwd)"
export BUILDOUTD="/tmp"
export BBPATH="$HERE/libs:$BBPATH"

die() {
    echo ">>> $*"
    echo
    exit 1
}

loadlib() {
    local libname

}

main() {
    [[ -n "$*" ]] || die "No libs specified"

    local rcname rcfile targetname all_libs_filelibname
    rcname="uselibrc"
    rcfile="$BUILDOUTD/$rcname"
    all_libs_name="src-$rcname"
    all_libs_file="$BUILDOUTD/bbuild/$all_libs_name"
    built_libs_file="$BUILDOUTD/$all_libs_name"

    mkdir -p "$BUILDOUTD/bbuild"

    echo > "$all_libs_file"

    for libname in "$@"; do
        [[ -f "$libname" ]] || die "Not a file '$libname'"
        cat "$libname" >> "$all_libs_file"
    done

    bbuild "$all_libs_file" # to built_libs_file
    cat "$HOME/.bashrc" > "$rcfile"
    cat "$built_libs_file" >> "$rcfile"
    echo "PS1=\"uselib > \"" >> "$rcfile"

    bash --rcfile "$rcfile"
}

main "$@"
