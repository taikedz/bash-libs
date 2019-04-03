#%include std/syntax-extensions.sh

##bash-libs: strings.sh @ %COMMITHASH%

### Strings library Usage:bbuild
#
# More advanced string manipulation functions.
#
###/doc

### strings:join JOINER STRINGS ... Usage:bbuild
#
# Join multiple strings, separated by the JOINER string
#
# Write the joined string to stdout
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

### strings:split *RETURN_ARRAY SPLITTER STRING Usage:bbuild
#
# Split a STRING along each instance of SPLITTER
#
# Write the result to the variable in RETURN_ARRAY (pass as name reference)
#
# e.g.
#
#   local my_array
#
#   strings:split my_array ":" "a:b c:d"
#
#   echo "${my_array[1]}" # --> "b c"
#
###/doc

$%function strings:split(*p_returnarray splitter string_to_split) {
    local items=(:)

    while [[ -n "$string_to_split" ]]; do
        if [[ ! "$string_to_split" =~ "${splitter}" ]]; then
            items[${#items[@]}]="$string_to_split"
            break
        fi

        local token="$(echo "$string_to_split"|sed -r "s${splitter}.*$")"
        items+=("$token")
        string_to_split="$(echo "$string_to_split"|sed "s^${token}${splitter}")"
    done

    p_returnarray=("${items[@]:1}")
}
