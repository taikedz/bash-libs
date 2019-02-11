#!/usr/bin/env bash

##bash-libs: safe.sh @ 1c36f035 (2.1)

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
# Using bash's defaults, array assignments split over any whitespace.
#
# Using safe mode, arrays only split over newlines, not over spaces.
#
# Return to default unsafe behaviour using `safe:space-split on`
#
# Reactivate safe recommendation using `safe:space-split off`
#
# Globs
# -------
#
# In safe mode, glob expansion like `ls .config/*` is turned off by default.
#
# You can turn glob expansion on with `safe:glob on`, and off with `safe:glob off`
#
###/doc

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

set -eufo pipefail
safe:space-split off
##bash-libs: tty.sh @ 1c36f035 (2.1)

tty:is_ssh() {
    [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ "$SSH_CONNECTION" ]]
}

tty:is_pipe() {
    [[ ! -t 1 ]]
}

##bash-libs: colours.sh @ 1c36f035 (2.1)

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

##bash-libs: out.sh @ 1c36f035 (2.1)

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
##bash-libs: patterns.sh @ 1c36f035 (2.1)

### Useful patterns Usage:bbuild
#
# Some useful regex patterns, exported as environment variables.
#
# They are not foolproof, and you are encouraged to improve upon them.
#
# $PAT_blank - detects whether an entire line is empty or whitespace
# $PAT_comment - detects whether is a line is a script comment (assumes '#' as the comment marker)
# $PAT_num - detects whether the string is an integer number in its entirety
# $PAT_cvar - detects if the string is a valid C variable name
# $PAT_filename - detects if the string is a safe UNIX or Windows file name;
#   does not allow presence of whitespace or special characters aside from '_', '.', '-'
# $PAT_email - simple heuristic to determine whether a string looks like a valid email address
#
###/doc

export PAT_blank='^\s*$'
export PAT_comment='^\s*(#.*)?$'
export PAT_num='^[0-9]+$'
export PAT_cvar='^[a-zA-Z_][a-zA-Z0-9_]*$'
export PAT_filename='^[a-zA-Z0-9_.-]$'
export PAT_email="$PAT_filename@$PAT_filename.$PAT_cvar"

##bash-libs: debug.sh @ 1c36f035 (2.1)

### Debug lib Usage:bbuild
#
# Debugging tools and functions.
#
# You need to activate debug mode using debug:activate command at the start of your script
#  (or from whatever point you wish it to activate)
#
###/doc

### Environment Variables Usage:bbuild
#
# DEBUG_mode : set to 'true' to enable debugging output
#
###/doc

: ${DEBUG_mode=false}

### debug:mode [output | /output | verbose | /verbose] ... Usage:bbuild
#
# Activate debug output (`output`), or activate command tracing (`verbose`)
#
# Deactivate with the corresponding `/output` and `/verbose` options
#
###/doc

function debug:mode() {
    local mode_switch
    for mode_switch in "$@"; do
        case "$mode_switch" in
        output)
            DEBUG_mode=true ;;
        /output)
            DEBUG_mode=false ;;
        verbose)
            set -x ;;
        /verbose)
            set +x ;;
        esac
    done
}

### debug:print MESSAGE Usage:bbuild
# print a blue debug message to stderr
# only prints if DEBUG_mode is set to "true"
###/doc
function debug:print {
    [[ "$DEBUG_mode" = true ]] || return 0
    echo "${CBBLU}DEBUG: $CBLU$*$CDEF" 1>&2
}

### debug:dump [MARKER] Usage:bbuild
#
# Pipe the data coming through stdin to stdout (as if it weren't there at all)
#
# If debug mode is on, *also* write the same data to stderr, each line preceded by MARKER
#
# Insert this function into pipes to see their output when in debugging mode
#
#   sed -r 's/linux|unix/*NIX/gi' myfile.txt | debug:dump | lprint
#
# Or use this to mask a command's output unless in debug mode
#
#   which binary 2>&1 | debug:dump >/dev/null
#
###/doc
function debug:dump {
    if [[ "$DEBUG_mode" = true ]]; then
        local MARKER="${1:-DEBUG: }"; shift || :

        cat - | sed -r "s/^/$MARKER/" | tee -a /dev/stderr
    else
        cat -
    fi
}

### debug:break MESSAGE Usage:bbuild
#
# Add break points to a script
#
# Requires `DEBUG_mode` set to true
#
# When the script runs, the message is printed with a prompt, and execution pauses.
#
# Press return to continue execution.
#
# Type a variable name, with leading `$`, to dump it, e.g. `$myvar`
#
# Type a variable name, with leading `$`, follwoed by an assignment to change its value, e.g. `$myvar=new value`
#  the new value will be seen by the script.
#
# Type 'env' to dump the current environment variables.
#
# Type `exit`, `quit` or `stop` to stop the program. If the breakpoint is in a subshell,
#  execution from after the subshell will be resumed.
#
###/doc

function debug:break {
    [[ "$DEBUG_mode" = true ]] || return 0
    local reply

    while true; do
        read -p "${CRED}BREAKPOINT: $* >$CDEF " reply
        if [[ "$reply" =~ quit|exit|stop ]]; then
            echo "${CBRED}ABORT${CDEF}" >&2
            exit 127

        elif [[ "$reply" = env ]]; then
            env |sed 's//^[/g' |debug:dump "--- "

        elif [[ "$reply" =~ ^\$ ]]; then
            debug:_break_dump "${reply:1}" || :

        elif [[ -z "$reply" ]]; then
            return 0
        else
            debug:print "'quit','exit' or 'stop' to abort; '\$varname' to see a variable's contents; '\$varname=new value' to assign a new value for run time; <Enter> to continue"
        fi
    done
}

debug:_break_dump() {
    local inspectable="$1"
    local varname="$1"
    local varval

    if [[ "$inspectable" =~ = ]]; then
        varname="${inspectable%%=*}"
        varval="${inspectable#*=}"
    fi

    [[ "$varname" =~ $PAT_cvar ]] || {
        debug:print "${CRED}Invalid var name '$varname'"
        return 1
    }

    declare -n inspect="$varname"

    if [[ "$inspectable" =~ = ]]; then
        inspect="$varval"
    else
        echo "$inspect"
    fi
}

##bash-libs: syntax-extensions.sh @ 1c36f035 (2.1)

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

##bash-libs: app/git.sh @ 1c36f035 (2.1)

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

# Do not clear by default
CLEAR_EXISTING_LIBS="${CLEAR_EXISTING_LIBS:-false}"

copy_lib() {
    local file_from="$1"; shift
    local dir_to="$1"; shift
    local file_dest="$dir_to/$(basename "$file_from")"

    mkdir -p "$dir_to"

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

    (git checkout master && git pull) || out:fail "Could not update the repository!"

    if [[ "$target" = latest-release ]]; then
        local version
        version="$(git:last_tagged_version)" || out:fail "Error obtaining last release!"
        target="${version:1}"
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

clear_libs_dir() {
    . <(args:use:local libsdirname -- "$@") ; 
    if [[ "${CLEAR_EXISTING_LIBS:-}" = true ]] && [[ -d "$libsdirname" ]]; then
        out:info "Removing old '$libsdirname' ..."
        rm -r "$libsdirname"
    else
        out:info "${CBPUR}Skip clearing $libsdirname"
    fi
}

set_libs_dir() {
    if [[ "$UID" = 0 ]]; then
        : ${libsdir="/usr/local/lib/bash-builder"}
    else
        : ${libsdir="$HOME/.local/lib/bash-builder"}
    fi
}

version_and_copy_libfiles() {
    for libsdirsrc in libs/* ; do
        if [[ "$libsdirsrc" =~ /\*$ ]]; then out:fail "Could not find source libraries"; fi

        local libsdirname="$(basename "$libsdirsrc")"
        local libsdirdest="$libsdir/$libsdirname"

        clear_libs_dir "$libsdirdest"

        for libfile in "$libsdirsrc"/*.sh ; do
            copy_lib "$libfile" "$libsdirdest" || out:fail "ABORT"
        done
    done
}

main() {
    safe:glob on
    cd "$(dirname "$0")"

    parse_args "$@"

    checkout_target "$TARGET_CHECKOUT"

    set_libs_dir

    load_bashlibs_version
    out:info "Installing libs versioned at: $COMMIT_VERSION"

    version_and_copy_libfiles

    echo -e "\033[32;1mSuccessfully installed libraries to [$libsdir]\033[0m"

    git checkout master
}

main "$@"
