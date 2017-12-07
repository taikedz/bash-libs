#!/bin/bash

### abspath Usage:bbuild
# Returns the absolute path of a file/directory
#
# Exposes two functions
#
#     abspath:path
#     abspath:simple
#
# Do not use the python-based 'abspath:path' for intensitve resolution;
# instead, use native 'abspath:simple' which is at least 170 times
# more efficient, at the cost of perhaps being potentially
# dumber (simply collapses '/./' and '/../').
# 
# Neither utility expands softlinks.
#
# If python is not found, abspath:path falls back to abspath:simple systematically.
###/doc

function abspath:path {
	local newvar=${1//"'"/"\\'"}
	(
		set +eu
		if which python >/dev/null 2>&1; then
			python  -c "import os ; print os.path.abspath('$newvar')"
		elif which python3 >/dev/null 2>&1 ; then
			python3 -c "import os ; print(os.path.abspath('$newvar') )"
		else
			abspath:simple "$newvar"
		fi
	)
}

# More efficient by a factor of at least 170:1
# compared to spinning up a python process every time
function abspath:simple {
	local workpath="$1"
	if [[ "${workpath:0:1}" != "/" ]]; then workpath="$PWD/$workpath"; fi
	for x in {1..50}; do # set a limit on how many iterations - only very stupid paths will get us here.
		if [[ "$workpath" =~ '/../' ]] || [[ "$workpath" =~ '/./' ]]; then
			workpath="$(echo "$workpath"|sed -r -e 's#/./#/#g' -e 's#([^/]+)/../#\1/#g' -e 's#/.$##' -e 's#([^/]+)/..$#\1#' )"
		else
			echo "$workpath"
			return 0
		fi
	done
	return 1 # hopefully we never get here
}
