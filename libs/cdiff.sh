#%include colours.sh

cdiff() {
    diff -u "$1" "$2" | colorize
}

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
