### Strings library Usage:bbuild
#
# More advanced string manipulation functions.
#
###/doc

### strings:join JOINER STRINGS ... Usage:bbuild
#
# Join multiple strings, separated by the JOINER string
#
###/doc

strings:join() {
	# joiner can be any string
	local joiner="$1"; shift || :

	# so we use an array to collect the token parts
	local destring=(:)

	for token in "$@"; do
		destring[${#destring[@]}]="$joiner"
		destring[${#destring[@]}]="$token"
	done

	local finalstring=""
	# first remove holder token and initial join token
	#   before iterating
	for item in "${destring[@]:2}"; do
		finalstring="${finalstring}${item}"
	done
	echo "$finalstring"
}

### strings:split SPLITTER STRING Usage:bbuild
#
# Split a STRING along each instance of SPLITTER
#
# Returns result in a STRINGS_ARR_SPLITS array
#
###/doc

strings:split() {
	local splitter="$1"; shift || :
	local string_to_split="$1"; shift || :

	local items=("")

	while [[ -n "$string_to_split" ]]; do
		if [[ ! "$string_to_split" =~ "${splitter}" ]]; then
			items[${#items[@]}]="$string_to_split"
			break
		fi

		local token="$(echo "$string_to_split"|sed -r "s${splitter}.*$")"
		items[${#items[@]}]="$token"
		string_to_split="$(echo "$string_to_split"|sed "s^${token}${splitter}")"
	done

	STRINGS_ARR_SPLITS=("${items[@]:1}")
}
