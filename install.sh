#!/usr/bin/env bash

##bash-libs: safe.sh @ 6421286a-uncommitted (2.0.1)

### Safe mode Usage:bbuild
#
# Set global safe mode options
#
# * Script bails if a statement or command returns non-zero status
#   * except when in a conditional statement
# * Accessing a variable that is not set is an error, causing non-zero status of the operation
# * Prevents globs
# * If a component of a pipe fails, the entire pipe statement returns non-zero
#
# Splitting over spaces
# ---------------------
#
# You can also switch space splitting on or off (normal bash default is 'on')
#
# Given a function `foo()` that returns multiple lines, which may each have spaces in them, use safe splitting to return each item into an array as its own item, without splitting over spaces.
#
#   safe:space-split off
#   mylist=(foo)
#   safe:space-split on
#
# Having space splitting on causes statements like `echo "$*"` to print each argument on its own line.
#
# Globs
# -------
#
# In safe mode, glob expansion like `ls .config/*` is turned off by default.
#
# You can turn glob expansion on and off with `safe:glob on` or `safe:glob off`
#
###/doc

set -eufo pipefail

safe:space-split() {
    case "$1" in
    off)
        export IFS=$'\t\n'
        ;;
    on)
        export IFS=$' \t\n'
        ;;
    *)
        out:fail "API error: bad use of safe:split - must be 'on' or 'off' not '$1'"
        ;;
    esac
}

safe:glob() {
    case "$1" in
    off)
        set -f
        ;;
    on)
        set +f
        ;;
    *)
        out:fail "API error: bad use of safe:glob - must be 'on' or 'off' not '$1'"
        ;;
    esac
}
##bash-libs: tty.sh @ 6421286a-uncommitted (2.0.1)

tty:is_ssh() {
    [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ "$SSH_CONNECTION" ]]
}

tty:is_pipe() {
    [[ ! -t 1 ]]
}

##bash-libs: colours.sh @ 6421286a-uncommitted (2.0.1)

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

##bash-libs: out.sh @ 6421286a-uncommitted (2.0.1)

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
##bash-libs: git.sh @ 6421286a-uncommitted (2.0.1)

### Git handlers Usage:bbuild
#
# Some handler functions wrapping git, for automation scripts that pull/update git repositories.
#
###/doc

### git:ensure URL [DIRPATH] Usage:bbuild
#
# Clone a repository, optionally to a directory path or ./<reponame> when none specified
#
# If a repository already exists here, check that the URL matches at least one remote,
#   if so, update
#   if not, return error
#
# Error codes used
# 10 - no URL
# 11 - directory exists, and is not a git repo
# 12 - directory exists, but the specified URL was not among the remotes
#
###/doc

git:clone() {
    local url dirpath reponame
    url="${1:-}"; shift || :
    [[ -n "$url" ]] || return 10

    reponame="$(basename "$url")"
    reponame="${reponame%*.git}"

    dirpath="${1:-./$reponame}"

    [[ -d "$dirpath" ]] || {
        git clone "$url" "$dirpath"
        return "$?"
    }

    [[ -d "$dirpath/.git" ]] || {
        return 11
    }

    ( cd "$dirpath" ; git remote -v | grep "$url" -q ) || {
        return 12
    }

    ( cd "$dirpath" ; git:update master )
}

### git:update [BRANCH [REMOTE] ] Usage:bbuild
#
# Check out a branch (default master), stashing if needed, and pull the latest changes from remote (default origin)
#
# 10 - Untracked files present; cannot stash, cannot pull
# 11 - stash failed
# 12 - no remotes
#
###/doc

git:update() {
    local status_string branch remote

    branch="${1:-master}"; shift || :
    remote="${1:-origin}"; shift || :

    [[ $(git remote -v | wc -l | cut -d' ' -f2) -gt 0 ]] || return 12

    status_string="$(git status)"
    if ! ( echo "$status_string" | grep "working tree clean" -iq ) ; then
        if echo "$status_string" | grep -e "^Untracked files:" -q ; then return 10 ; fi

        git stash || return 11
    fi

    git pull "$remote" "$branch" || return 12
}

### git:last_tagged_version Usage:bbuild
#
# Look through history of the current branch and find the latest version tag
#
# If a version is found, that version is echoed, with a prefix:
#
# * "=" if the current commit is tagged with the latest version found
# * ">" if the current commit is later than the latest version found
#
# If no version is round, returns with status 1
#
###/doc

git:last_tagged_version() {
    local tagpat='(?<=tag: )([vV]\.?)?[0-9.]+'
    local tagged_version
    tagged_version="$(git log --oneline -n 1 --format="%d" | grep -oP "$tagpat")" || :

    if [[ -z "$tagged_version" ]]; then
        tagged_version="$(git log --format="%d"|grep -vP '^\s*$' | grep -oP "$tagpat" -m 1)" || :
        if [[ -z "$tagged_version" ]]; then
            return 1
        fi

        tagged_version=">$tagged_version"
    else
        tagged_version="=$tagged_version"
    fi

    echo "$tagged_version"
}
##bash-libs: syntax-extensions.sh @ 6421286a-uncommitted (2.0.1)

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
        failmsg="\"Internal : could not get '$argname' in function arguments\""
        posfailmsg="Internal: positional argument '$argname' encountered after optional argument(s)"

        if [[ "$argname" =~ ^\? ]]; then
            echo "$SYNTAXLIB_scope ${argname:1}=$argone; shift || :"
            pos_ok=false

        elif [[ "$argname" =~ ^\* ]]; then
            [[ "$pos_ok" != false ]] || out:fail "$posfailmsg"
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

copy_lib_dir() {
    . <(args:use:local libsrc -- "$@") ; 
    local srcname="$(basename "$libsrc")"

    # We copy only the end dir by name
    # TODO use libsrc in full as sub-path to libsdir
    mkdir -p "$libsdir/$srcname"

    for libfile in "$libsrc"/*.sh ; do
        copy_lib "$libfile" "$libsdir/$srcname/" || out:fail "ABORT"
    done
}

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    sed "s/\%COMMITHASH\%/$COMMIT_VERSION/" "$file_from" > "$file_dest"

    chmod 644 "$file_dest"
}

parse_args() {
    local arg

    CLEAR_EXISTING_LIBS=true
    TARGET_CHECKOUT=latest-release

    for arg in "$@"; do
    case "$arg" in
    --no-clear)
        CLEAR_EXISTING_LIBS=false
        ;;
    *)
        TARGET_CHECKOUT="$arg"
        ;;
    esac
    done
}

checkout_target() {
    . <(args:use:local ?target -- "$@") ; 
    if [[ -z "$target" ]]; then return 0; fi

    if [[ "$target" = latest-release ]]; then
        target="$(git log --oneline --decorate=short | grep -oP '(?<=\(tag: )[0-9.]+' | head -n 1)"
    fi

    git checkout "$target" || out:fail "Could not checkout commit at [$target]"
}

load_bashlibs_version() {
    local state version

    version="$(git:last_tagged_version)" || out:fail "Error obtaining bash libs version!"
    state="${version:0:1}"

    if [[ "$state" = '=' ]]; then
        state=""
    else
        state="after "
    fi

    BASHLIBS_VERSION="${state}${version:1}"

    load_commit_version
}

load_commit_version() {
    local commit="$(git log -n 1|head -n 1|cut -f2 -d' ')"

    COMMIT_VERSION="${commit:0:8}$(git_status) ($BASHLIBS_VERSION)"
}

git_status() {
    if git status | grep -E "working (tree|directory) clean" -q ; then
        : # clean state, echo nothing
    else
        echo "-uncommitted"
    fi
}

clear_libs() {
    if [[ "${CLEAR_EXISTING_LIBS:-}" = true ]] && [[ -d "$libsdir" ]]; then
        echo "Removing old '$libsdir' ..."
        rm -r "$libsdir"
    fi
}

set_libs_dir() {
    if [[ "$UID" = 0 ]]; then
        : ${libsdir="/usr/local/lib/bash-builder"}
    else
        : ${libsdir="$HOME/.local/lib/bash-builder"}
    fi
}

main() {
    safe:glob on
    cd "$(dirname "$0")"

    parse_args "$@"

    checkout_target "$TARGET_CHECKOUT"

    set_libs_dir
    clear_libs

    mkdir -p "$libsdir"

    load_bashlibs_version
    out:info "Installing libs versioned at: $COMMIT_VERSION"

    copy_lib_dir std

    echo -e "\033[32;1mSuccessfully installed libraries to [$libsdir]\033[0m"
}

main "$@"
