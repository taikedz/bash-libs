#!/bin/bash

### Verification script Usage:help
# Build scripts and run unit tests
#
# [norm=true] [runtests=false] [bbflags='-c'] ./verify [LIBFILES ...]
#
# * `norm=true` : do not remove test artifacts
# * `runtests=false` : do not run unit tests, just check that he files build
# * `bbflags='-c'` : run shellcheck (via `bbuild` feature)
#
# Any LIBFILE must be in the form of "./lib/SOMEFILE" , the corresponding test
#  that will be searched for wil then be "./tests/test-SOMEFILE"
###/doc

##bash-libs: tty.sh @ 9d200ab4-uncommitted (2.0.6)

tty:is_ssh() {
    [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ "$SSH_CONNECTION" ]]
}

tty:is_pipe() {
    [[ ! -t 1 ]]
}

##bash-libs: colours.sh @ 9d200ab4-uncommitted (2.0.6)

### Colours for terminal Usage:bbuild
# A series of shorthand colour flags for use in outputs, and functions to set your own flags.
#
# Not all terminals support all colours or modifiers.
#
# Example:
# 	
# 	echo "${CRED}Some red text ${CBBLU} some blue text. $CDEF Some text in the terminal's default colour")
#
# Preconfigured colours available:
#
# CRED, CBRED, HLRED -- red, bright red, highlight red
# CGRN, CBGRN, HLGRN -- green, bright green, highlight green
# CYEL, CBYEL, HLYEL -- yellow, bright yellow, highlight yellow
# CBLU, CBBLU, HLBLU -- blue, bright blue, highlight blue
# CPUR, CBPUR, HLPUR -- purple, bright purple, highlight purple
# CTEA, CBTEA, HLTEA -- teal, bright teal, highlight teal
# CBLA, CBBLA, HLBLA -- black, bright red, highlight red
# CWHI, CBWHI, HLWHI -- white, bright red, highlight red
#
# Modifiers available:
#
# CBON - activate bright
# CDON - activate dim
# ULON - activate underline
# RVON - activate reverse (switch foreground and background)
# SKON - activate strikethrough
# 
# Resets available:
#
# CNORM -- turn off bright or dim, without affecting other modifiers
# ULOFF -- turn off highlighting
# RVOFF -- turn off inverse
# SKOFF -- turn off strikethrough
# HLOFF -- turn off highlight
#
# CDEF -- turn off all colours and modifiers(switches to the terminal default)
#
# Note that highlight and underline must be applied or re-applied after specifying a colour.
#
# If the session is detected as being in a pipe, colours will be turned off.
#   You can override this by calling `colours:check --color=always` at the start of your script
#
###/doc

### colours:check ARGS ... Usage:bbuild
#
# Check the args to see if there's a `--color=always` or `--color=never`
#   and reload the colours appropriately
#
#   main() {
#       colours:check "$@"
#
#       echo "${CGRN}Green only in tty or if --colours=always !${CDEF}"
#   }
#
#   main "$@"
#
###/doc
colours:check() {
    if [[ "$*" =~ --color=always ]]; then
        COLOURS_ON=true
    elif [[ "$*" =~ --color=never ]]; then
        COLOURS_ON=false
    fi

    colours:define
    return 0
}

### colours:set CODE Usage:bbuild
# Set an explicit colour code - e.g.
#
#   echo "$(colours:set "33;2")Dim yellow text${CDEF}"
#
# See SGR Colours definitions
#   <https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters>
###/doc
colours:set() {
    # We use `echo -e` here rather than directly embedding a binary character
    if [[ "$COLOURS_ON" = false ]]; then
        return 0
    else
        echo -e "\033[${1}m"
    fi
}

colours:define() {

    # Shorthand colours

    export CBLA="$(colours:set "30")"
    export CRED="$(colours:set "31")"
    export CGRN="$(colours:set "32")"
    export CYEL="$(colours:set "33")"
    export CBLU="$(colours:set "34")"
    export CPUR="$(colours:set "35")"
    export CTEA="$(colours:set "36")"
    export CWHI="$(colours:set "37")"

    export CBBLA="$(colours:set "1;30")"
    export CBRED="$(colours:set "1;31")"
    export CBGRN="$(colours:set "1;32")"
    export CBYEL="$(colours:set "1;33")"
    export CBBLU="$(colours:set "1;34")"
    export CBPUR="$(colours:set "1;35")"
    export CBTEA="$(colours:set "1;36")"
    export CBWHI="$(colours:set "1;37")"

    export HLBLA="$(colours:set "40")"
    export HLRED="$(colours:set "41")"
    export HLGRN="$(colours:set "42")"
    export HLYEL="$(colours:set "43")"
    export HLBLU="$(colours:set "44")"
    export HLPUR="$(colours:set "45")"
    export HLTEA="$(colours:set "46")"
    export HLWHI="$(colours:set "47")"

    # Modifiers
    
    export CBON="$(colours:set "1")"
    export CDON="$(colours:set "2")"
    export ULON="$(colours:set "4")"
    export RVON="$(colours:set "7")"
    export SKON="$(colours:set "9")"

    # Resets

    export CBNRM="$(colours:set "22")"
    export HLOFF="$(colours:set "49")"
    export ULOFF="$(colours:set "24")"
    export RVOFF="$(colours:set "27")"
    export SKOFF="$(colours:set "29")"

    export CDEF="$(colours:set "0")"

}

colours:auto() {
    if tty:is_pipe ; then
        COLOURS_ON=false
    else
        COLOURS_ON=true
    fi

    colours:define
    return 0
}

colours:auto

##bash-libs: out.sh @ 9d200ab4-uncommitted (2.0.6)

### Console output handlers Usage:bbuild
#
# Write data to console stderr using colouring
#
###/doc

### out:info MESSAGE Usage:bbuild
# print a green informational message to stderr
###/doc
function out:info {
    echo "$CGRN$*$CDEF" 1>&2
}

### out:warn MESSAGE Usage:bbuild
# print a yellow warning message to stderr
###/doc
function out:warn {
    echo "${CBYEL}WARN: $CYEL$*$CDEF" 1>&2
}

### out:defer MESSAGE Usage:bbuild
# Store a message in the output buffer for later use
###/doc
function out:defer {
    OUTPUT_BUFFER_defer[${#OUTPUT_BUFFER_defer[@]}]="$*"
}

# Internal
function out:buffer_initialize {
    OUTPUT_BUFFER_defer=(:)
}
out:buffer_initialize

### out:flush HANDLER ... Usage:bbuild
#
# Pass the output buffer to the command defined by HANDLER
# and empty the buffer
#
# Examples:
#
# 	out:flush echo -e
#
# 	out:flush out:warn
#
# (escaped newlines are added in the buffer, so `-e` option is
#  needed to process the escape sequences)
#
###/doc
function out:flush {
    [[ -n "$*" ]] || out:fail "Did not provide a command for buffered output\n\n${OUTPUT_BUFFER_defer[*]}"

    [[ "${#OUTPUT_BUFFER_defer[@]}" -gt 1 ]] || return 0

    for buffer_line in "${OUTPUT_BUFFER_defer[@]:1}"; do
        "$@" "$buffer_line"
    done

    out:buffer_initialize
}

### out:fail [CODE] MESSAGE Usage:bbuild
# print a red failure message to stderr and exit with CODE
# CODE must be a number
# if no code is specified, error code 127 is used
###/doc
function out:fail {
    local ERCODE=127
    local numpat='^[0-9]+$'

    if [[ "$1" =~ $numpat ]]; then
        ERCODE="$1"; shift || :
    fi

    echo "${CBRED}ERROR FAIL: $CRED$*$CDEF" 1>&2
    exit $ERCODE
}

### out:error MESSAGE Usage:bbuild
# print a red error message to stderr
#
# unlike out:fail, does not cause script exit
###/doc
function out:error {
    echo "${CBRED}ERROR: ${CRED}$*$CDEF" 1>&2
}

##bash-libs: syntax-extensions.sh @ 9d200ab4-uncommitted (2.0.6)

### Syntax Extensions Usage:syntax
#
# Syntax extensions for bash-builder.
#
# You will need to import this library if you use Bash Builder's extended syntax macros.
#
# You should not however use the functions directly, but the extended syntax instead.
#
##/doc

### syntax-extensions:use FUNCNAME ARGNAMES ... Usage:syntax
#
# Consume arguments into named global variables.
#
# If not enough argument values are found, the first named variable that failed to be assigned is printed as error
#
# ARGNAMES prefixed with '?' do not trigger an error
#
# Example:
#
#   #%include out.sh
#   #%include syntax-extensions.sh
#
#   get_parameters() {
#       . <(syntax-extensions:use get_parameters INFILE OUTFILE ?comment)
#
#       [[ -f "$INFILE" ]]  || out:fail "Input file '$INFILE' does not exist"
#       [[ -f "$OUTFILE" ]] || out:fail "Output file '$OUTFILE' does not exist"
#
#       [[ -z "$comment" ]] || echo "Note: $comment"
#   }
#
#   main() {
#       get_parameters "$@"
#
#       echo "$INFILE will be converted to $OUTFILE"
#   }
#
#   main "$@"
#
###/doc
syntax-extensions:use() {
    local argname arglist undef_f dec_scope argidx argone failmsg pos_ok
    
    dec_scope=""
    [[ "${SYNTAXLIB_scope:-}" = local ]] || dec_scope=g
    arglist=(:)
    argone=\"\${1:-}\"
    pos_ok=true
    
    for argname in "$@"; do
        [[ "$argname" != -- ]] || break
        [[ "$argname" =~ ^(\?|\*)?[0-9a-zA-Z_]+$ ]] || out:fail "Internal: Not a valid argument name '$argname'"

        arglist+=("$argname")
    done

    argidx=1
    while [[ "$argidx" -lt "${#arglist[@]}" ]]; do
        argname="${arglist[$argidx]}"
        failmsg="\"Internal: could not get '$argname' in function arguments\""
        posfailmsg="Internal: positional argument '$argname' encountered after optional argument(s)"

        if [[ "$argname" =~ ^\? ]]; then
            echo "$SYNTAXLIB_scope ${argname:1}=$argone; shift || :"
            pos_ok=false

        elif [[ "$argname" =~ ^\* ]]; then
            [[ "$pos_ok" != false ]] || out:fail "$posfailmsg"
            echo "[[ '${argname:1}' != \"$argone\" ]] || out:fail \"Internal: Local name [$argname] equals upstream [$argone]. Rename [$argname] (suggestion: [*p_${argname:1}])\""
            echo "declare -n${dec_scope} ${argname:1}=$argone; shift || out:fail $failmsg"

        else
            [[ "$pos_ok" != false ]] || out:fail "$posfailmsg"
            echo "$SYNTAXLIB_scope ${argname}=$argone; shift || out:fail $failmsg"
        fi

        argidx=$((argidx + 1))
    done
}


### syntax-extensions:use:local FUNCNAME ARGNAMES ... Usage:syntax
# 
# Enables syntax macro: function signatures
#   e.g. $%function func(var1 var2) { ... }
#
# Build with bbuild to leverage this function's use:
#
#   #%include out.sh
#   #%include syntax-extensions.sh
#
#   $%function person(name email) {
#       echo "$name <$email>"
#
#       # $1 and $2 have been consumed into $name and $email
#       # The rest remains available in $* :
#       
#       echo "Additional notes: $*"
#   }
#
#   person "Jo Smith" "jsmith@example.com" Some details
#
###/doc
syntax-extensions:use:local() {
    SYNTAXLIB_scope=local syntax-extensions:use "$@"
}

args:use:local() {
    syntax-extensions:use:local "$@"
}

##bash-libs: autohelp.sh @ 9d200ab4-uncommitted (2.0.6)

### Autohelp Usage:bbuild
#
# Autohelp provides some simple facilities for defining help as comments in your code.
# It provides several functions for printing specially formatted comment sections.
#
# Write your help as documentation comments in your script
#
# To output a named section from your script, or a file, call the
# `autohelp:print` function and it will print the help documentation
# in the current script, or specified file, to stdout
#
# A help comment looks like this:
#
#    ### <title> Usage:help
#    #
#    # <some content>
#    #
#    # end with "###/doc" on its own line (whitespaces before
#    # and after are OK)
#    #
#    ###/doc
#
# It can then be printed from the same script by simply calling
#
#   autohelp:print
#
# You can print a different section by specifying a different name
#
# 	autohelp:print section2
#
# > This would print a section defined in this way:
#
# 	### Some title Usage:section2
# 	# <some content>
# 	###/doc
#
# You can set a different comment character by setting the 'HELPCHAR' environment variable.
# Typically, you might want to print comments you set in a INI config file, for example
#
# 	HELPCHAR=";" autohelp:print help config-file.ini
# 
# Which would then find comments defined like this in `config-file.ini`:
#
#   ;;; Main config Usage:help
#   ; Help comments in a config file
#   ; may start with a different comment character
#   ;;;/doc
#
#
#
# Example usage in a multi-function script:
#
#   #!usr/bin/env bash
#
#   ### Main help Usage:help
#   # The main help
#   ###/doc
#
#   ### Feature One Usage:feature_1
#   # Help text for the first feature
#   ###/doc
#
#   feature1() {
#       autohelp:check:section feature_1 "$@"
#       echo "Feature I"
#   }
#
#   ### Feature Two Usage:feature_2
#   # Help text for the second feature
#   ###/doc
#
#   feature2() {
#       autohelp:check:section feature_2 "$@"
#       echo "Feature II"
#   }
#
#   main() {
#       case "$1" in
#       feature1|feature2)
#           "$1" "$@"            # Pass the global script arguments through
#           ;;
#       *)
#           autohelp:check-no-null "$@"  # Check if main help was asked for, if so, or if no args, exit with help
#
#           # Main help not requested, return error
#           echo "Unknown feature"
#           exit 1
#           ;;
#       esac
#   }
#
#   main "$@"
#
###/doc

### autohelp:print [ SECTION [FILE] ] Usage:bbuild
# Print the specified section, in the specified file.
#
# If no file is specified, prints for current script file.
# If no section is specified, defaults to "help"
###/doc

HELPCHAR='#'

autohelp:print() {
    local input_line
    local section_string="${1:-}"; shift || :
    local target_file="${1:-}"; shift || :
    [[ -n "$section_string" ]] || section_string=help
    [[ -n "$target_file" ]] || target_file="$0"

    local sec_start='^\s*'"$HELPCHAR$HELPCHAR$HELPCHAR"'\s+(.+?)\s+Usage:'"$section_string"'\s*$'
    local sec_end='^\s*'"$HELPCHAR$HELPCHAR$HELPCHAR"'\s*/doc\s*$'
    local in_section=false

    while read input_line; do
        if [[ "$input_line" =~ $sec_start ]]; then
            in_section=true
            echo -e "\n${BASH_REMATCH[1]}\n======="

        elif [[ "$in_section" = true ]]; then
            if [[ "$input_line" =~ $sec_end ]]; then
                in_section=false
            else
                echo "$input_line" | sed -r "s/^\s*$HELPCHAR/ /;s/^  (\S)/\1/"
            fi
        fi
    done < "$target_file"

    if [[ "$in_section" = true ]]; then
            out:fail "Non-terminated help block."
    fi
}

### autohelp:paged Usage:bbuild
#
# Display the help in the pager defined in the PAGER environment variable
#
###/doc
autohelp:paged() {
    : ${PAGER=less}
    autohelp:print "$@" | $PAGER
}

### autohelp:check-or-null ARGS ... Usage:bbuild
# Print help if arguments are empty, or if arguments contain a '--help' token
#
###/doc
autohelp:check-or-null() {
    if [[ -z "$*" ]]; then
        autohelp:print help "$0"
        exit 0
    else
        autohelp:check:section "help" "$@"
    fi
}

### autohelp:check-or-null:section SECTION ARGS ... Usage:bbuild
# Print help section SECTION if arguments are empty, or if arguments contain a '--help' token
#
###/doc
autohelp:check-or-null:section() {
    . <(args:use:local section -- "$@") ; 
    if [[ -z "$*" ]]; then
        autohelp:print "$section" "$0"
        exit 0
    else
        autohelp:check:section "$section" "$@"
    fi
}

### autohelp:check ARGS ... Usage:bbuild
#
# Automatically print "help" sections and exit, if "--help" is detected in arguments
#
###/doc
autohelp:check() {
    autohelp:check:section "help" "$@"
}

### autohelp:check:section SECTION ARGS ... Usage:bbuild
# Automatically print documentation for named section and exit, if "--help" is detected in arguments
#
###/doc
autohelp:check:section() {
    local section arg
    section="${1:-}"; shift || out:fail "No help section specified"

    for arg in "$@"; do
        if [[ "$arg" =~ --help ]]; then
            cols="$(tput cols)"
            autohelp:print "$section" | fold -w "$cols" -s || autohelp:print "$section"
            exit 0
        fi
    done
}
##bash-libs: runmain.sh @ 9d200ab4-uncommitted (2.0.6)

### runmain SCRIPTNAME FUNCTION [ARGUMENTS ...] Usage:bbuild
#
# Runs the function FUNCTION with ARGUMENTS, only if the runtime
# name of the script matches SCRIPTNAME
#
# This allows you include a main-like function in your library
# that only runs if you use your lib as an executabl itself.
#
# For example, an image archiver could be:
#
# 	function archive_images {
# 		tar czf "$1.tgz" "$@"
# 	}
#
# 	runmain archiveimages.sh archive_images "$@"
#
# When included a different script, the runmain call does not fire the lib's function
#
# If the lib is compiled/made executable, and named "archiveimages.sh", the function runs.
#
# This is similar to `if __name__ == "__main__"` clauses in python
#
###/doc

function runmain {
    local required_name="$1"; shift || :
    local funcall="$1"; shift || :
    local scriptname="$(basename "$0")"

    if [[ "$required_name" = "$scriptname" ]]; then
        "$funcall" "$@"
    fi
}

cd "$(dirname "$0")"
export BUILDOUTD=/tmp
export BBPATH=./

items=0
VER_fails=0
: ${runtests=true}

set_executable() {
    if [[ -z "${BBEXEC:-}" ]]; then
        export BBEXEC=bbuild
    fi

    if [[ ! -f "$BBEXEC" ]] && ! which "$BBEXEC" >/dev/null 2>/dev/null; then
        out:fail 1 "Cannot use [$BBEXEC] to run builds - no such file or command"
    fi

    out:info "Build using \`$BBEXEC\` command"
}

set_targets() {
    targets=(std/*.sh)

    if [[ "$#" -gt 0 ]]; then
        targets=("$@")
    fi
}

rmfile() {
    [[ "${norm:-}" = true ]] && return || :

    rm "$@" || :
}

run_build_test() {
    local scriptname="$1"; shift

    "$BBEXEC" ${bbflags:-} "$libscript" || {
        VER_fails=$((VER_fails+1))
        return 1
    }

    return 0
}

run_unit_tests() {
    [[ "${runtests:-}" = true ]] || return

    local scriptname="$1"; shift
    local testname="test-$scriptname"
    local testsfile="tests/$testname"

    if [[ -f "$testsfile" ]]; then
        "$BBEXEC" "$testsfile"
        bash ${bashflags:-} "/tmp/$testname" || VER_fails=$((VER_fails+1))
    else
        VER_fails=$((VER_fails+1))
        out:warn "There is no $testsfile test file."
    fi
}

run_verification() {
    for libscript in "${targets[@]}"; do
        local scriptname="$(basename "$libscript")"

        items=$((items+1))

        run_build_test "$scriptname" || continue

        run_unit_tests "$scriptname"

        rmfile "/tmp/$scriptname"
    done
}

main() {
    autohelp:check "$@"

    set_executable
    set_targets "$@"
    run_verification

    echo -e "\n\n\n"
    local endmsg="Verification --- Built $items items with $VER_fails failures."

    if [[ "$VER_fails" -gt 0 ]]; then
        out:fail "$VER_fails" "$endmsg"
    else
        out:info "$endmsg"
    fi
}

time runmain verify.sh main "$@"
