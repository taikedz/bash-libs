### Strings library Usage:bbuild
#
# More advanced string manipulation functions.
#
###/doc

### strings:join JOINER STRINGS ... Usage:bbuild
#
# Join multiple strings, separate by the JOINER string
#
###/doc

strings:join() {
	local joiner="$1"; shift

	local destring=""

	for token in "$@"; do
		destring="${destring:-}${joiner}${token}"
	done

	echo "${destring:1}"
}

### strings:split SPLITTER STRING Usage:bbuild
#
# Split a STRING along each instance of SPLITTER
#
# Returns result in a STRINGS_ARR_SPLITS array
#
###/doc

strings:split() {
	local splitter="$1"; shift
	local string_to_split="$1"; shift

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
