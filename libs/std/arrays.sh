#%include std/syntax-extensions.sh

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
# It is also impossible to pass environment variable arrays to sub
#  processes.
#
# This library allows you to pass back a "serialized array."
#
# Recipients of the serialized array must use the deserialization
#  function on each token to retrive its original content.
#
#
# EXAMPLE
#
# This example generates a sequence of first and last names; each pair is
#   space-separated, so needs to be serialized before being returned.
#
# 	get_names() {
# 		local sdata name
# 		sdata=
#
# 		for name in "Alice Alson" "Bob Robertson" "Carol Carlson"; do
# 			sdata="$sdata $(arrays:serialize "$name")"
# 		done
#       
# 		echo $sdata
# 	}
#
# 	names="$(get_names)"
# 	# $names is a string, and can be passed down to processes.
#
#
#   # +++++++
# 	# Use case 1a : get a single item by index, and decode it
#
# 	arrays:get 2 $names
#   # Not quoting the variable splits it automatically
#
#   # 1b : Assigning using parentheses () splits string along whitespace
#   #  to form an array of serialized tokens. The serialized data can then
#   #  be accessed by index
#
#   a_names=($names)
#   echo "${a_names[2]}"
#
#
#   # +++++++
#   # Use case 2 : storing the serialized tokens as an array, for iteration
#
# 	for person in $names ; do
# 		arrays:get "$person"
# 	done
#
#
###/doc

### arrays:get { IDX TOKENS ... | TOKEN } Usage:bbuild
#
# Deserialize the IDX'th item in TOKENS
#
# or
#
# Deserialize TOKEN
#
###/doc
arrays:get() {
    local idx inner_array
    idx="$1"; shift

    if [[ -n "$*" ]]; then # Extract from serialized array
        inner_array=($*)
        [[ $idx -lt ${#inner_array[@]} ]] || return 1
        [[ $idx -ge 0 ]] || return 1
        arrays:_deserialize_one "${inner_array[$idx]}"

    else # No array passed; presume idx is in fact a serialized token
        arrays:_deserialize_one "$idx"
    fi
}

# Internal - see arrays:get for API use
#
# Deserialize a single token
arrays:_deserialize_one() {
    echo "$1" | base64 -d
}

### arrays:deserialize ARRAYNAME TOKENS ... Usage:bbuild
#
# Deserialize all tokens into the referenced array.
#
# Note that ARRAYNAME is a string of the array name, not the
#   array values themselves.
#
###/doc
$%function arrays:deserialize(*p_return_array) {
    local token
    for token in "$@"; do
        p_return_array+=("$(arrays:_deserialize_one "$token")")
    done
}

### arrays:serialize ARGUMENTS ... Usage:bbuild
# 
# Given an array of arguments, return them as a space-separated list
#   of serialized tokens.
#
###/doc
arrays:serialize() {
    local sdata x
    sdata=''

    for x in "$@"; do
        sdata="$sdata $(echo "$x"|base64 -w0)"
    done

    echo $sdata
}
