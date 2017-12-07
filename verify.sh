cd "$(dirname "$0")"

export BUILDOUTD=/tmp

items=0
fails=0

for libscript in libs/*.sh; do
	items=$((items+1))
	bbuild "$libscript" || fails=$((fails+1))
done

echo "Built $items items with $fails failures."

exit "$fails"
