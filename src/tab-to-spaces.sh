tabspace_file() {
    while grep -qP '^#?\t' "$1"; do
        sed -r 's/^(#?\t*)\t/\1    /g' -i "$1"
    done
}

main() {
    local f
    for f in "$@"; do
        tabspace_file "$f"
    done
}

main "$@"
