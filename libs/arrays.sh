##bash-libs: arrays.sh @ %COMMITHASH%

### Arrays Library Usage:bbuild
#
# Lib for handling array serialization
#
# In Bash, arrays are built by splitting along whitespace.
#  This makes it impossible for functions and commands to natively
#  return array data whose tokens contain whitespace, or even
#  empty-string-tokens.
#
# This library allows you to pass back a "serialized array."
#
# Recipients of the serialized array must use the deserialization
#  function on each token to retrive its original content.
#
# This library is implemented purely with bash language constructs
#  and not external commands, for the sake of portability and
#  performance.
#
#
# EXAMPLE
#
# This example adds the token string "Hello " to its arguments.
#
# Its output is array-serialized, so that any code that calls it
#  can store an array without needing to resolve splitting issues
#
# 	greet_all() {
# 		local newarray=()
# 		for name in "$@"; do
# 			newarray[${#newarray[@]}]="Hello $name"
# 		done
#		
#		# Serialize the array - prints serialized data to stdout
# 		arrays:ser "${newarray[@]}"
# 	}
#
#	# Assigning using parentheses () splits string along whitespace to form an array
#	#  of serialized tokens
# 	all_greetings=( $(greet_all "Alice Alson" "Bob Robertson" "Carol Carlson") )
#
# 	for greeting in "${all_greetings[@]}"; do
# 		arrays:des "$greeting"
# 	done
#
#
###/doc

ARRAYSLIB_c_tb="	"
ARRAYSLIB_c_lf="$(echo -e "\012")"
ARRAYSLIB_c_cr="$(echo -e "\015")"

arrays:ser() {
	arrays:serialize "$@"
}

arrays:des() {
	arrays:deserialize "$@"
}

arrays:serialize() {
	local serialdata=()
	local item

	for item in "$@"; do
		item="${item// /%s}"
		item="${item//$ARRAYSLIB_c_tb/%t}"
		item="${item//$ARRAYSLIB_c_lf/%n}"
		item="${item//$ARRAYSLIB_c_cr/%r}"

		if [[ -z "$item" ]]; then
			item="%0"
		fi

		serialdata[${#serialdata[@]}]="$item"
	done

	echo "${serialdata[*]}"
}

arrays:deserialize() {
	local item="$1"; shift

	if [[ "$item" = "%0" ]]; then
		echo ""
		return 0
	fi

	item="${item//%s/ }"
	item="${item//%t/$ARRAYSLIB_c_tb}"
	item="${item//%n/$ARRAYSLIB_c_lf}"
	item="${item//%r/$ARRAYSLIB_c_cr}"

	echo "$item"
}
