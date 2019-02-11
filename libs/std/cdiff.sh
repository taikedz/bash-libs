#%include std/colours.sh

##bash-libs: cdiff.sh @ %COMMITHASH%

### cdiff FILE1 FILE2 Usage:bbuild
#
# Colour-print the differences from `FILE1` to `FILE2`
#
###/doc
cdiff() {
    diff -u "$1" "$2" | colorize
}

### | colorize Usage:bbuild
#
# Colour print diff input on stdin
#
###/doc
colorize() {
    local line

    while read line; do
        if [[ "$line" =~ ^\+ ]]; then
            echo "${CBGRN}$line"
        elif [[ "$line" =~ ^- ]]; then
            echo "${CBRED}$line"
        elif [[ "$line" =~ @@ ]]; then
            echo "${CBYEL}$line"
        else
            echo "${CDEF}$line"
        fi
    done
    echo "${CDEF}"
}
