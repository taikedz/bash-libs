#!/bin/bash

set -euo pipefail

die() {
    echo "$*"
    exit 1
}

last_commit() {
    local commit="$(git log -n 1|head -n 1|cut -f2 -d' ')"

    echo "${commit:0:8}$(git_status) ($BASHLIBS_VERSION)"
}

git_status() {
    if git status | grep -E "working (tree|directory) clean" -q ; then
        : # clean state, echo nothing
    else
        echo "-uncommitted"
    fi
}

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    sed "s/\%COMMITHASH\%/$(last_commit)/" "$file_from" > "$file_dest"

    chmod 644 "$file_dest"
}

checkout_target() {
    if [[ -z "$*" ]]; then return 0; fi

    git checkout "$1" || die "Could not checkout commit at [$1]"
}

load_bashlibs_version() {
    local tagpat='(?<=tag: )[0-9.]+'
    BASHLIBS_VERSION="$(git log --oneline -n 1 --decorate=short | grep -oP "$tagpat")" || :

    if [[ -z "$BASHLIBS_VERSION" ]]; then
        # piping git log to grep always generates an error ; and we only care if grep fails
        # hence unset pipefail locally
        BASHLIBS_VERSION="after $(set +o pipefail; git log --oneline --decorate=short | grep -oP "$tagpat" -m 1)" || die "Could not get Bash Libs version"
    fi
}

clear_libs() {
    if [[ "${CLEAR_EXISTING_LIBS:-}" = true ]] && [[ -d "$libs" ]]; then
        echo "Clearing '$libs' ..."
        rm -r "$libs"
    fi
}

set_libs_dir() {
    if [[ "$UID" == 0 ]]; then
        : ${libs="/usr/local/lib/bbuild"}
    else
        : ${libs="$HOME/.local/lib/bbuild"}
    fi
}

main() {
    cd "$(dirname "$0")"

    checkout_target "$@"

    set_libs_dir
    clear_libs

    mkdir -p "$libs"

    load_bashlibs_version

    for libfile in libs/*.sh ; do
        copy_lib "$libfile" "$libs/" || die "ABORT"
    done

    echo -e "\033[32;1mSuccessfully installed libraries to [$libs]\033[0m"
}

main "$@"
