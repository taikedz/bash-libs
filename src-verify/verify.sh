#!/bin/bash

### Verification script Usage:help
# Build scripts and run unit tests
#
# [norm=true] [runtests=false] [bbflags='-c'] ./verify [LIBFILES ...]
#
# * `norm=true` : do not remove test artifacts
# * `runtests=false` : do not run unit tests, just check that he files build
# * `bbflags='-c'` : run shellcheck (via `bbuild` feature)
#
# Any LIBFILE must be in the form of "./lib/SOMEFILE" , the corresponding test
#  that will be searched for wil then be "./tests/test-SOMEFILE"
###/doc

#%include autohelp.sh
#%include out.sh
#%include colours.sh
#%include runmain.sh

cd "$(dirname "$0")"
export BUILDOUTD=/tmp
export BBPATH=libs/

items=0
fails=0
: ${runtests=true}

set_executable() {
	if [[ -z "${BBEXEC:-}" ]]; then
		export BBEXEC=bbuild
	fi

	if [[ ! -f "$BBEXEC" ]] && ! which "$BBEXEC" >/dev/null 2>/dev/null; then
		out:fail 1 "Cannot use [$BBEXEC] to run builds - no such file or command"
	fi

	out:info "Build using \`$BBEXEC\` command"
}

set_targets() {
	targets=(libs/*.sh)

	if [[ "$#" -gt 0 ]]; then
		targets=("$@")
	fi
}

rmfile() {
	[[ "${norm:-}" = true ]] && return || :

	rm "$@" || :
}

run_build_test() {
	local scriptname="$1"; shift

	"$BBEXEC" ${bbflags:-} "$libscript" || {
		rmfile "/tmp/$scriptname"
		fails=$((fails+1))
		continue
	}
}

run_unit_tests() {
	[[ "${runtests:-}" = true ]] || return

	local scriptname="$1"; shift
	local testname="test-$scriptname"
	local testsfile="tests/$testname"

	if [[ -f "$testsfile" ]]; then
		"$BBEXEC" "$testsfile"
		MODE_DEBUG="${MODE_DEBUG:-}" bash ${bashflags:-} "/tmp/$testname" || fails=$((fails+1))
	else
		out:warn "There is no $testsfile test file."
	fi
}

run_verification() {
	for libscript in "${targets[@]}"; do
		local scriptname="$(basename "$libscript")"

		items=$((items+1))

		run_build_test "$scriptname"

		run_unit_tests "$scriptname"

		rmfile "/tmp/$scriptname"
	done
}

main() {
	autohelp:check "$@"

	set_executable
	set_targets "$@"
	run_verification

	echo -e "\n\n\n"
	local endmsg="Verification --- Built $items items with $fails failures."

	if [[ "$fails" -gt 0 ]]; then
		out:fail "$fails" "$endmsg"
	else
		out:info "$endmsg"
	fi
}

time runmain verify.sh main "$@"
