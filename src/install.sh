#!/usr/bin/env bash

#%include std/safe.sh
#%include std/out.sh
#%include std/git.sh
#%include std/syntax-extensions.sh

$%function copy_lib_dir(libsrc) {
    local srcname="$(basename "$libsrc")"

    # We copy only the end dir by name
    # TODO use libsrc in full as sub-path to libsdir
    mkdir -p "$libsdir/$srcname"

    for libfile in "$libsrc"/*.sh ; do
        copy_lib "$libfile" "$libsdir/$srcname/" || out:fail "ABORT"
    done
}

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    sed "s/\%COMMITHASH\%/$COMMIT_VERSION/" "$file_from" > "$file_dest"

    chmod 644 "$file_dest"
}

parse_args() {
    local arg

    CLEAR_EXISTING_LIBS=true
    TARGET_CHECKOUT=latest-release

    for arg in "$@"; do
    case "$arg" in
    --no-clear)
        CLEAR_EXISTING_LIBS=false
        ;;
    *)
        TARGET_CHECKOUT="$arg"
        ;;
    esac
    done
}

$%function checkout_target(?target) {
    if [[ -z "$target" ]]; then return 0; fi

    if [[ "$target" = latest-release ]]; then
        target="$(git log --oneline --decorate=short | grep -oP '(?<=\(tag: )[0-9.]+' | head -n 1)"
    fi

    git checkout "$target" || out:fail "Could not checkout commit at [$target]"
}

load_bashlibs_version() {
    local state version

    version="$(git:last_tagged_version)" || out:fail "Error obtaining bash libs version!"
    state="${version:0:1}"

    if [[ "$state" = '=' ]]; then
        state=""
    else
        state="after "
    fi

    BASHLIBS_VERSION="${state}${version:1}"

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
        : ${libsdir="/usr/local/lib/bash-builder"}
    else
        : ${libsdir="$HOME/.local/lib/bash-builder"}
    fi
}

main() {
    safe:glob on
    cd "$(dirname "$0")"

    parse_args "$@"

    checkout_target "$TARGET_CHECKOUT"

    set_libs_dir
    clear_libs

    mkdir -p "$libsdir"

    load_bashlibs_version
    out:info "Installing libs versioned at: $COMMIT_VERSION"

    copy_lib_dir std

    echo -e "\033[32;1mSuccessfully installed libraries to [$libsdir]\033[0m"
}

main "$@"
