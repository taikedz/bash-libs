#!/usr/bin/env bash

main() {
    for file in "$@"; do
        grep -qP 'test:require|test:forbid' "$file" || echo "$file"
    done
}

main "$@"
