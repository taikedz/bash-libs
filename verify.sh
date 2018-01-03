cd "$(dirname "$0")"

export BUILDOUTD=/tmp
export BBPATH=libs/

items=0
fails=0

targets=(libs/*.sh)

if [[ "$#" -gt 0 ]]; then
	targets=("$@")
fi

for libscript in "${targets[@]}"; do
	items=$((items+1))
	bbuild "$libscript" || {
		fails=$((fails+1))
		continue
	}

	libname="$(basename "$libscript")"
	if [[ -f "tests/test-$libname" ]]; then
		bbuild "tests/test-$libname"
		bash "/tmp/test-$libname" || fails=$((fails+1))
	fi
done

echo "Built $items items with $fails failures."

exit "$fails"
