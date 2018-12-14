#%include std/colours.sh
#%include std/patterns.sh

##bash-libs: debug.sh @ %COMMITHASH%

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
