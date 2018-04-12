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
# 		local sdata token
# 		sdata=""
#
# 		for name in "$@"; do
# 		    token=$(arrays:serialize "Hello $name")
# 			sdata="$sdata $token"
# 		done
#       
#       # Specifically, do not wrap in quotes
# 		echo $sdata
# 	}
#
#
#   # +++++++
# 	# Use case 1 : store serialization in a string
#
# 	all_greetings="$(greet_all "Alice Alson" "Bob Robertson" "Carol Carlson")"
#
# 	arrays:get 2 $all_greetings
#
#
#   # +++++++
#   # Use case 2 : storing the serialized tokens as an array, for iteration
#
#   # Assigning using parentheses () splits string along whitespace to form an array
#   #  of serialized tokens
#
# 	for greeting in $all_greetings ; do    # By not quoting the string, it splits on its own
# 		arrays:get "$greeting"
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
        arrays:deserialize "${inner_array[$idx]}"

    else # No array passed; presume idx is in fact a serialized token
        arrays:deserialize "$idx"
    fi
}

if [[ "${ARRAYSLIB_mode:-}" = escapes ]]; then

    ### Obfuscating implementation
    # Has some issues with newlines....

    ARRAYSLIB_c_tb="$(echo -e '\t')"
    ARRAYSLIB_c_lf="$(echo -e "\012")"
    ARRAYSLIB_c_cr="$(echo -e "\015")"

    ARRAYSLIB_s_sp="$(echo -e "\033%s")"
    ARRAYSLIB_s_tb="$(echo -e "\033%t")"
    ARRAYSLIB_s_lf="$(echo -e "\033%n")"
    ARRAYSLIB_s_cr="$(echo -e "\033%r")"
    ARRAYSLIB_s_es="$(echo -e "\033%0")"

    ### arrays:serialize ARGUMENTS ... Usage:bbuild
    # 
    # Given an array of arguments, return them as a space-separated list
    #   of serialized tokens.
    #
    ###/doc
    arrays:serialize() {
        local serialdata item

        for item in "$@"; do

            if [[ -z "$item" ]]; then
                item="$ARRAYSLIB_s_es"
            else
                item="${item// /$ARRAYSLIB_s_sp}"
                item="${item//$ARRAYSLIB_c_tb/$ARRAYSLIB_s_tb}"
                item="${item//$ARRAYSLIB_c_lf/$ARRAYSLIB_s_lf}"
                item="${item//$ARRAYSLIB_c_cr/$ARRAYSLIB_s_cr}"
            fi

            serialdata="${serialdata:-} $item"
        done

        echo $serialdata
    }

    # Internal - see arrays:get for API use
    #
    # Deserialize a single token
    arrays:deserialize() {
        local item
        item="$1"; shift

        if [[ "$item" = "$ARRAYSLIB_s_es" ]]; then
            echo ""
            return 0
        fi

        item="${item//$ARRAYSLIB_s_sp/ }"
        item="${item//$ARRAYSLIB_s_tb/$ARRAYSLIB_c_tb}"
        item="${item//$ARRAYSLIB_s_lf/$ARRAYSLIB_c_lf}"
        item="${item//$ARRAYSLIB_s_cr/$ARRAYSLIB_c_cr}"

        echo "$item"
    }

else

    arrays:serialize() {
        local sdata x
        sdata=''

        for x in "$@"; do
            sdata="$sdata $(echo "$x"|base64 -w0)"
        done

        echo $sdata
    }

    arrays:deserialize() {
        echo "$1" | base64 -d
    }

fi
