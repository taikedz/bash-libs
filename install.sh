#!/bin/bash

last_commit() {
    local commit="$(git log -n 1|head -n 1|cut -f2 -d' ')"

    echo "${commit:0:8}$(git_status) ($BASHLIBS_VERSION)"
}

git_status() {
    if git status | grep -E "working (tree|directory) clean" -q ; then
        : # echo "clean"
    else
        echo "-modified"
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

    git checkout "$1" || {
        echo "Could not checkout commit at [$1]"
        exit 1
    }
}

main() {
    cd "$(dirname "$0")"

    checkout_target "$@"

    if [[ "$UID" == 0 ]]; then
        : ${libs="/usr/local/lib/bbuild"}
    else
        : ${libs="$HOME/.local/lib/bbuild"}
    fi

    mkdir -p "$libs"

    # populate BASHLIBS_VERSION
    . versionrc

    for libfile in libs/*.sh ; do
        copy_lib "$libfile" "$libs/"
    done

    echo -e "\033[32;1mSuccessfully installed libraries to [$libs]\033[0m"
}

main "$@"
