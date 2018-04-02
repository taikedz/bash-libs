##bash-libs: sums.sh @ %COMMITHASH%

#%include out.sh

### hsum Usage:bbuild
#
# Pipe function to sum numbers with "humanized" magnitudeinations
#
# e.g.
#
#	du -sh * | hsum:sum 1024
#
#	distances | hsum:sum
#
# BASE is the base of the order of magnitude, by default 1000
#
###/doc

hsum:sum() {
	local base="${1:-1000}"

	local numpat="([0-9]+(\.[0-9]+)?)"
	local sumtotal=0

	local kb=$base
	local mb=$(($base*$base))
	local gb=$(($base*$base*$base))
	local tb=$(($base*$base*$base*$base))

	while read qtty; do
		[[ -n "$qtty" ]] || continue

		if [[ "$qtty" =~ $numpat(k|K|m|M|g|G|t|T) ]]; then
			local x=${BASH_REMATCH[1]}
			local magnitude=${BASH_REMATCH[3]}

			if [[ $magnitude =~ k|K ]]; then
				x=$(echo "$x * $kb"|bc)

			elif [[ $magnitude =~ m|M ]]; then
				x=$(echo "$x*$mb"|bc)

			elif [[ $magnitude =~ g|G ]]; then
				x=$(echo "$x*$gb"|bc)

			elif [[ $magnitude =~ t|T ]]; then
				x=$(echo "$x*$tb"|bc)

			else
				out:debug "Could not act on magnitude [$magnitude]"
				return 1
			fi

			out:debug "$qtty -> Adding $x to $sumtotal"
			sumtotal=$(echo "$sumtotal + $x"|bc)
		else
			out:debug "Ignoring $qtty"
		fi
	done

	[[ "$sumtotal" =~ ^([0-9]+) ]]
	local intpart=${BASH_REMATCH[1]}

	if [[ "$intpart" -lt $kb ]]; then
		echo "$sumtotal bytes"

	elif [[ "$intpart" -lt $mb ]]; then
		echo "$(echo "$sumtotal/$kb"|bc)KB"

	elif [[ "$intpart" -lt $gb ]]; then
		echo "$(echo "$sumtotal/$mb"|bc)MB"

	elif [[ "$intpart" -lt $tb ]]; then
		echo "$(echo "$sumtotal/$gb"|bc)GB"

	else
		echo "$(echo "$sumtotal/$tb"|bc)TB"
	fi
		
}
