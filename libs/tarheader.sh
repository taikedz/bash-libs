#!/bin/bash

set -euo pipefail

### Extraction header Usage:bbuild
#
# Predictably extracts to a preferred destination, by default ./
#   set TSH_D environment variable to determine where unpacked applications should go
#
# If the application needs re-extracting, run the script with just one argument:
#
# 	:unpack
#
###/doc

# ===========================================================================
##bash-libs: abspath.sh @ aa3101b7-modified

### abspath:path RELATIVEPATH [ MAX ] Usage:bbuild
# Returns the absolute path of a file/directory
#
# MAX defines the maximum number of "../" relative items to process
#   default is 50
###/doc

function abspath:path {
    local workpath="$1" ; shift || :
    local max="${1:-50}" ; shift || :

    if [[ "${workpath:0:1}" != "/" ]]; then workpath="$PWD/$workpath"; fi

    workpath="$(abspath:collapse "$workpath")"
    abspath:resolve_dotdot "$workpath" "$max" | sed -r 's|(.)/$|\1|'
}

function abspath:collapse {
    echo "$1" | sed -r 's|/\./|/|g ; s|/\.$|| ; s|/+|/|g'
}

function abspath:resolve_dotdot {
    local workpath="$1"; shift || :
    local max="$1"; shift || :

    # Set a limit on how many iterations to perform
    # Only very obnoxious paths should fail
    for x in $(seq 1 $max); do
        # No more dot-dots - good to go
        if [[ ! "$workpath" =~ /\.\.(/|$) ]]; then
            echo "$workpath"
            return 0
        fi

        # Starts with an up-one at root - unresolvable
        if [[ "$workpath" =~ ^/\.\.(/|$) ]]; then
            return 1
        fi

        workpath="$(echo "$workpath"|sed -r 's@[^/]+/\.\.(/|$)@@')"
    done

    # A very obnoxious path was used.
    return 2
}
# ===========================================================================

tarsh:unpack() {
    trap tarsh:cleanup EXIT SIGINT

    if [[ "$TSH_D" != /tmp ]] && [[ -d "$TARSH_unpackdir" ]]; then
        # not an auto-cleaning dir
        # and some version exists
        return
    fi

    mkdir -p "$TARSH_unpackdir"

    hashline=$(egrep --binary-files=text -n "^$TARSH_binhash$" "$0" | cut -d: -f1)

    tail -n +"$((hashline + 1))" "$0" | tar xz -C "$TARSH_unpackdir"
}

tarsh:run() {
    PATH="$TARSH_unpackdir/bin:$PATH" TARWD="$TARSH_unpackdir" "$TARSH_unpackdir/bin/main.sh" "$@"
}

tarsh:cleanup() {
    if [[ -d "$TARSH_unpackdir" ]] && [[ "$TSH_D" = ./ ]] && [[ "${TARSH_noclean:-}" != true ]]; then
        rm -r "$TARSH_unpackdir"
    fi
}

tarsh:modecheck() {
    if [[ "${1:-}" = ":unpack" ]]; then
        tarsh:unpack
        TARSH_noclean=true
        exit
    fi
}

tarsh:set_unpack_destination() {
    : ${TSH_D=./}
}

main() {

    tarsh:set_unpack_destination

    TARSH_binhash="%TARSH_ID%"

    TARSH_unpackdir="$(abspath:path "$TSH_D/$(basename "$0")-$TARSH_binhash.d")"

    tarsh:modecheck "$@"

    tarsh:unpack

    tarsh:run "$@"

}

main "$@"
exit 0

%TARSH_ID%
