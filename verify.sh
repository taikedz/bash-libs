cd "$(dirname "$0")"

export BUILDOUTD=/tmp
export BBPATH=libs/

items=0
fails=0

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

check_runtests() {
	runtests=no

	if [[ "${dotest:-}" =~ ^(y|Y|yes|YES)$ ]]; then
		runtests=yes
	else
		echo -e "\033[33;1mYou can run tests by setting the env var \`\$dotest\` to \`y\` \033[0m"
	fi
}

set_targets() {
	targets=(libs/*.sh)

	if [[ "$#" -gt 0 ]]; then
		targets=("$@")
	fi
}

run_verification() {
	for libscript in "${targets[@]}"; do
		local scriptname="$(basename "$libscript")"

		items=$((items+1))
		"$BBEXEC" ${bbflags:-} "$libscript" || {
			rm "/tmp/$scriptname"
			fails=$((fails+1))
			continue
		}

		if [[ ! "$runtests" = yes ]]; then
			rm "/tmp/$scriptname"
			continue
		fi

		local testname="test-$scriptname"
		if [[ -f "tests/$testname" ]]; then
			"$BBEXEC" "tests/$testname"
			bash "/tmp/$testname" || fails=$((fails+1))
			rm "/tmp/$testname"
		else
			echo -e "\033[33;1mWarning: there is no tests/$testname test file.\033[0m"
		fi
		rm "/tmp/$scriptname"
	done
}

main() {
	set_executable
	check_runtests
	set_targets "$@"
	run_verification

	echo "Built $items items with $fails failures."

	exit "$fails"
}

main "$@"
