cd "$(dirname "$0")"

### Verification script Usage:help
# Build scripts and run unit tests
#
# [runtests=false] [bbflags='-c'] ./verify [LIBFILES ...]
#
# Any LIBFILE must be in the form of "./lib/FILENAME"
###/doc

. libs/autohelp.sh

export BUILDOUTD=/tmp
export BBPATH=libs/

items=0
fails=0
runtests=true

set_executable() {
	if [[ -z "${BBEXEC:-}" ]]; then
		export BBEXEC=bbuild
	fi

	if [[ ! -f "$BBEXEC" ]] && ! which "$BBEXEC" >/dev/null 2>/dev/null; then
		echo -e "\033[31;1mCannot use [$BBEXEC] to run builds - no such file or command\033[0m"
		exit 1
	fi

	echo "Build using \`$BBEXEC\` command"
}

set_targets() {
	targets=(libs/*.sh)

	if [[ "$#" -gt 0 ]]; then
		targets=("$@")
	fi
}

rmfile() {
	[[ "${norm:-}" = true ]] && return || :

	rm "$@"
}

run_verification() {
	for libscript in "${targets[@]}"; do
		local scriptname="$(basename "$libscript")"

		items=$((items+1))
		"$BBEXEC" ${bbflags:-} "$libscript" || {
			rmfile "/tmp/$scriptname"
			fails=$((fails+1))
			continue
		}

		if [[ ! "${runtests:-}" = true ]]; then
			rmfile "/tmp/$scriptname"
			continue
		fi

		local testname="test-$scriptname"
		if [[ -f "tests/$testname" ]]; then
			"$BBEXEC" "tests/$testname"
			MODE_DEBUG="${MODE_DEBUG:-}" bash ${bashflags:-} "/tmp/$testname" || fails=$((fails+1))
			rmfile "/tmp/$testname"
		else
			echo -e "\033[33;1mWarning: there is no tests/$testname test file.\033[0m"
		fi
		rmfile "/tmp/$scriptname"
	done
}

main() {
	set_executable
	set_targets "$@"
	run_verification

	echo "Built $items items with $fails failures."

	exit "$fails"
}

if [[ "$*" =~ --help ]]; then
	autohelp:print
	exit 0
fi

main "$@"
