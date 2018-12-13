#!/bin/bash

set -euo pipefail

die() {
    echo "$*"
    exit 1
}

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    sed "s/\%COMMITHASH\%/$COMMIT_VERSION/" "$file_from" > "$file_dest"

    chmod 644 "$file_dest"
}

checkout_target() {
    if [[ -z "$*" ]]; then return 0; fi
    local target="$1"; shift

    if [[ "$target" = latest-release ]]; then
        target="$(git log --oneline --decorate=short | grep -oP '(?<=\(tag: )[0-9.]+' | head -n 1)"
    fi

    git checkout "$target" || die "Could not checkout commit at [$target]"
}

load_bashlibs_version() {
    local tagpat='(?<=tag: )[0-9.]+'
    BASHLIBS_VERSION="$(git log --oneline -n 1 --decorate=short | grep -oP "$tagpat")" || :

    if [[ -z "$BASHLIBS_VERSION" ]]; then
        # piping git log to grep always generates an error ; and we only care if grep fails
        # hence unset pipefail locally
        # FIXME this does not sound right though...
        BASHLIBS_VERSION="after $(set +o pipefail; git log --oneline --decorate=short | grep -oP "$tagpat" -m 1)" || die "Could not get Bash Libs version"
    fi

    load_commit_version
}

load_commit_version() {
    local commit="$(git log -n 1|head -n 1|cut -f2 -d' ')"

    COMMIT_VERSION="${commit:0:8}$(git_status) ($BASHLIBS_VERSION)"
}

git_status() {
    if git status | grep -E "working (tree|directory) clean" -q ; then
        : # clean state, echo nothing
    else
        echo "-uncommitted"
    fi
}

clear_libs() {
    if [[ "${CLEAR_EXISTING_LIBS:-}" = true ]] && [[ -d "$libsdir" ]]; then
        echo "Removing old '$libsdir' ..."
        rm -r "$libsdir"
    fi
}

set_libs_dir() {
    if [[ "$UID" = 0 ]]; then
        : ${libsdir="/usr/local/lib/bash-builder/std"}
    else
        : ${libsdir="$HOME/.local/lib/bash-builder/std"}
    fi
}

main() {
    cd "$(dirname "$0")"

    checkout_target "$@"

    set_libs_dir
    clear_libs

    mkdir -p "$libsdir"

    load_bashlibs_version

    for libfile in libs/*.sh ; do
        copy_lib "$libfile" "$libsdir/" || die "ABORT"
    done

    echo -e "\033[32;1mSuccessfully installed libraries to [$libsdir]\033[0m"
}

main "$@"
