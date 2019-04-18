#%include std/syntax-extensions.sh

##bash-libs: event.sh @ %COMMITHASH%

### Events Usage:bbuild
#
# Utility to implement event-like practices.
#
# Declare a function and subscribe it to any events
#
# ```sh
# funcname() {
#   # do stuff ...
# }
#
# event:subscribe funcname EVT1 EVT2 EVT3
# ```
#
# Event names are arbitrary, alphanumeric strings.
#
# > With bash-builder 6.2.3+ you can do this in one line
# >
# > ```sh
# > $%on EVENTS ... FUNCNAME() {}
# > ```
#
# Then from anywhere, trigger an event
#
# ```sh
# event:trigger EVTNAME [ARGS ...]
# ```
#
# This will call every event subscribed, in the order in which they subscribed, FIFO-style.
#
# You can remove an event from the chain anytime with `event:ubsubscribe funcname EVT1 EVT2 ...`
#
###/doc

# A map from (event name) --> (string of serialized function names)
declare -A STD_EVENT_LIB_EVENTS

### event:subscribe FUNCNAME EVENTS ... Usage:help
#
# Subscribe a function to one or more events.
#
# Returns 1 if an event name is invalid
# Returns 2 if a function name is invalid
#
###/doc
$%function event:subscribe(funcname) {
    local eventname
    for eventname in "$@"; do
        event:_append_function "$eventname" "$funcname" || return
    done
}

### event:subscribe FUNCNAME [EVENTS ...] Usage:help
#
# Unsubscribe a function to one or more events.
#
# If no events are specified, unsubscribes the function from all events.
#
###/doc
$%function event:ubsubscribe(funcname) {
    # If events specified, ubsubscribe function from each event
    # Else, unsubscribe from all events
    if [[ "$#" -gt 0 ]]; then
        local eventname
        for eventname in "$@"; do
            events:_remove_function "$eventname" "$funcname"
        done
    else
        events:_remove_all "$funcname"
    fi
}

### event:trigger EVENT [ARGS ...] Usage:help
#
# Run every function associated with the event, directly passing arguments if specified.
#
# When called, the function can access the triggered event through $1
#
###/doc
$%function event:trigger(eventname) {
    # Lookup event, call each function in turn with the remaining arguments

    [[ "$eventname" =~ ^[a-zA-Z0-9_.,:-]+$ ]] || return 1

    local f_list=( $(echo "${STD_EVENT_LIB_EVENTS["$eventname"]}"|sed -r 's/\s+/\n/g') )
    local funcname

    for funcname in "${f_list[@]}"; do
        "$funcname" "$eventname" "$@"
    done
}




$%function event:_add_event(eventname) {
    # Add an event if it does not exist already
    local f_list="${STD_EVENT_LIB_EVENTS["$eventname"]}"
    if [[ -z "$f_list" ]]; then
        STD_EVENT_LIB_EVENTS["$eventname"]=""
    fi
}

$%function event:_append_function(eventname funcname) {
    # Remove function from named event only

    [[ "$eventname" =~ ^[a-zA-Z0-9_.,:-]+$ ]] || return 1
    [[ "$funcname" =~ ^[a-zA-Z0-9_.,:-]+$ ]] || return 2

    local f_list="${STD_EVENT_LIB_EVENTS["$eventname"]}"
    STD_EVENT_LIB_EVENTS["$eventname"]="$f_list $funcname"
}

$%function event:_remove_function(eventname funcname) {
    # Remove function from named event only

    # Ensure split along newlines, in case space-splitting is off
    local f_list=( $(echo "${STD_EVENT_LIB_EVENTS["$eventname"]}"|sed -r 's/\s+/\n/g') )
    local new_f_list=(:)
    local fname

    for fname in "${f_list[@]}"; do
        if [[ ! "$fname" = "$funcname" ]]; then
            new_f_list+=("$fname")
        fi
    done

    STD_EVENT_LIB_EVENTS["$eventname"]="${new_f_list[*]:1}"
}

$%function event:_remove_all(funcname) {
    # Remove function from all events
    local eventname

    for eventname in "${!STD_EVENT_LIB_EVENTS[@]}"; do
        event:_remove_function "$eventname" "$funcname"
    done
}
