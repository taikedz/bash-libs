#!/usr/bin/env bash

#%include std/safe.sh
#%include std/out.sh
#%include std/debug.sh
#%include std/git.sh
#%include std/syntax-extensions.sh

# Do not clear by default
CLEAR_EXISTING_LIBS="${CLEAR_EXISTING_LIBS:-false}"

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    mkdir -p "$dir_to"

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

    (git checkout master && git pull) || out:fail "Could not update the repository!"

    if [[ "$target" = latest-release ]]; then
        local version
        version="$(git:last_tagged_version)" || out:fail "Error obtaining last release!"
        target="${version:1}"
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

$%function clear_libs_dir(libsdirname) {
    if [[ "${CLEAR_EXISTING_LIBS:-}" = true ]] && [[ -d "$libsdirname" ]]; then
        out:info "Removing old '$libsdirname' ..."
        rm -r "$libsdirname"
    else
        out:info "${CBPUR}Skip clearing $libsdirname"
    fi
}

set_libs_dir() {
    if [[ "$UID" = 0 ]]; then
        : ${libsdir="/usr/local/lib/bash-builder"}
    else
        : ${libsdir="$HOME/.local/lib/bash-builder"}
    fi
}

version_and_copy_libfiles() {
    for libsdirsrc in libs/* ; do
        if [[ "$libsdirsrc" =~ /\*$ ]]; then out:fail "Could not find source libraries"; fi

        local libsdirname="$(basename "$libsdirsrc")"
        local libsdirdest="$libsdir/$libsdirname"

        clear_libs_dir "$libsdirdest"

        for libfile in "$libsdirsrc"/*.sh ; do
            copy_lib "$libfile" "$libsdirdest" || out:fail "ABORT"
        done
    done
}

main() {
    safe:glob on
    cd "$(dirname "$0")"

    parse_args "$@"

    checkout_target "$TARGET_CHECKOUT"

    set_libs_dir

    load_bashlibs_version
    out:info "Installing libs versioned at: $COMMIT_VERSION"

    version_and_copy_libfiles

    echo -e "\033[32;1mSuccessfully installed libraries to [$libsdir]\033[0m"

    git checkout master
}

main "$@"
