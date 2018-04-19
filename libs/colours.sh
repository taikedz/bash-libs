##bash-libs: colours.sh @ %COMMITHASH%

### Colours for bash Usage:bbuild
# A series of colour flags for use in outputs.
#
# Example:
# 	
# 	echo -e "${CRED}Some red text ${CBBLU} some blue text $CDEF some text in the terminal's default colour")
#
# Requires processing of escape characters.
#
# Colours available:
#
# CRED, CBRED, HLRED -- red, bold red, highlight red
# CGRN, CBGRN, HLGRN -- green, bold green, highlight green
# CYEL, CBYEL, HLYEL -- yellow, bold yellow, highlight yellow
# CBLU, CBBLU, HLBLU -- blue, bold blue, highlight blue
# CPUR, CBPUR, HLPUR -- purple, bold purple, highlight purple
# CTEA, CBTEA, HLTEA -- teal, bold teal, highlight teal
#
# CDEF -- switches to the terminal default
# CUNL -- add underline
#
# Note that highlight and underline must be applied or re-applied after specifying a colour.
#
# If the session is detected as non-interactive, or in a pipe, colours will be turned off.
#   You can override this by calling `colours:check --color=always` at the start of your script
#
###/doc

#%include tty.sh

### colours:check ARGS Usage:bbuild
#
# Check the args to see if there's a `--color=always` or `--color=never`
#   and reload the colours appropriately
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

colours:auto() {
    if tty:is_pipe || ! tty:is_interactive ; then
        COLOURS_ON=false
    else
        COLOURS_ON=true
    fi

    colours:define
    return 0
}

colours:define() {
    if [[ "$COLOURS_ON" = true ]]; then

        export CRED=''
        export CGRN=''
        export CYEL=''
        export CBLU=''
        export CPUR=''
        export CTEA=''

        export CBRED=''
        export CBGRN=''
        export CBYEL=''
        export CBBLU=''
        export CBPUR=''
        export CBTEA=''

        export HLRED=''
        export HLGRN=''
        export HLYEL=''
        export HLBLU=''
        export HLPUR=''
        export HLTEA=''

        export CDEF=''

    else

        export CRED=$(echo -e "\033[0;31m")
        export CGRN=$(echo -e "\033[0;32m")
        export CYEL=$(echo -e "\033[0;33m")
        export CBLU=$(echo -e "\033[0;34m")
        export CPUR=$(echo -e "\033[0;35m")
        export CTEA=$(echo -e "\033[0;36m")

        export CBRED=$(echo -e "\033[1;31m")
        export CBGRN=$(echo -e "\033[1;32m")
        export CBYEL=$(echo -e "\033[1;33m")
        export CBBLU=$(echo -e "\033[1;34m")
        export CBPUR=$(echo -e "\033[1;35m")
        export CBTEA=$(echo -e "\033[1;36m")

        export HLRED=$(echo -e "\033[41m")
        export HLGRN=$(echo -e "\033[42m")
        export HLYEL=$(echo -e "\033[43m")
        export HLBLU=$(echo -e "\033[44m")
        export HLPUR=$(echo -e "\033[45m")
        export HLTEA=$(echo -e "\033[46m")

        export CDEF=$(echo -e "\033[0m")

    fi
}

colours:auto
