#%include std/syntax-extensions.sh
#%include std/patterns.sh

### Formatting library Usage:bbuild
#
# Some convenience functions for formatting output.
#
###/doc

### format:columns [SEP] Usage:bbuild
#
# Redirect input or pipe into this function to print columns using separator
#  (default is tab character).
#
# Each line is split along the separator characters (each individual character is a
#  separator, and the column widths are adjusted to the widest member of all rows.
#
# e.g.
#
#    format:columns ':' < /etc/passwd
#
#    grep January report.tsv | format:column
#
###/doc

$%function format:columns(?sep) {
    [[ -n "$sep" ]] || sep=$'\t'

    column -t -s "$sep"
}

### format:wrap Usage:bbuild
#
# Pipe or redirect into this function to soft-wrap text along spaces to terminal
#  width, or specified width.
#
# e.g.
#
#   format:wrap 40 < README.md
#
###/doc

$%function format:wrap(?cols) {
    [[ -n "$cols" ]] || cols="$(tput cols)"
    [[ "$cols" =~ $PAT_num ]] || return 1
    fold -w "$cols" -s
}
