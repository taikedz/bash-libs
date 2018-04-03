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

	TARSH_unpackdir="$TSH_D/$(basename "$0")-$TARSH_binhash.d"

	tarsh:modecheck "$@"

	tarsh:unpack

	tarsh:run "$@"

}

main "$@"
exit 0

%TARSH_ID%
