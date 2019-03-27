#%include std/colours.sh

##bash-libs: cdiff.sh @ %COMMITHASH%

### cdiff:cdiff FILE1 FILE2 Usage:bbuild
#
# Colour-print the differences from `FILE1` to `FILE2`
#
###/doc
cdiff:cdiff() {
    diff -u "$1" "$2" | colorize
}

### cdiff:colorize Usage:bbuild
#
# Colourize unified diff stream on stdin. Use as piped command.
#
###/doc
cdiff:colorize() {
    local sedrules=(
        -e "s/^((\\+\\+\\+|---).+)/${CBTEA}\\1${CDEF}/g"
        -e "s|^(\\+.*)|${CBGRN}\\1${CDEF}|g"
        -e "s|^(-.*)|${CBRED}\\1${CDEF}|g"
        -e "s|^(@@.*)|${CBBLU}\\1${CDEF}|g"
    )

    sed -r "${sedrules[@]}"
}
