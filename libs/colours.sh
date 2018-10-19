#%include tty.sh

##bash-libs: colours.sh @ %COMMITHASH%

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
