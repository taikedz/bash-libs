#!/usr/bin/env bbrun

#%include std/out.sh

main() {
    out:info "Lib files with no test file"
    for file in libs/std/*.sh; do
        file="$(basename "$file")"
        [[ -f "tests/test-$file" ]] || echo "$file"
    done

    out:info "Test files with no actual tests"
    for file in tests/test-*.sh; do
        grep -qP 'test:require|test:forbid' "$file" || echo "$file"
    done
}

main "$@"
