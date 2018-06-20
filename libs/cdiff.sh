#%include colours.sh

cdiff() {
    echo -e "< $1\n> $2" | colorize
    diff "$1" "$2" | colorize
}

colorize() {
    local line

    while read line; do
        if [[ "$line" =~ ^\> ]]; then
            echo "${CBGRN}$line"
        elif [[ "$line" =~ ^\< ]]; then
            echo "${CBRED}$line"
        else
            echo "${CBYEL}$line"
        fi
    done
    echo "${CDEF}"
}
