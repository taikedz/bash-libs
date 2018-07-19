##bash-libs: askuser.sh @ %COMMITHASH%

### askuser Usage:bbuild
# Present the user with questions on stderr
###/doc

#%include out.sh

yespat='^(yes|YES|y|Y)$'
numpat='^[0-9]+$'
rangepat='[0-9]+,[0-9]+'
listpat='^[0-9 ]+$'
blankpat='^ *$'

### askuser:confirm Usage:bbuild
# Ask the user to confirm a closed question. Defaults to no
#
# returns 0 on successfully match 'y' or 'yes'
# returns 1 otherwise
###/doc
function askuser:confirm {
    read -p "$* [y/N] > " 1>&2
    if [[ "$REPLY" =~ $yespat ]]; then
        return 0
    else
        return 1
    fi
}

### askuser:ask Usage:bbuild
# Ask the user to provide some text
#
# Echoes out the entered text
###/doc
function askuser:ask {
    read -p "$* : " 1>&2
    echo "$REPLY"
}

### askuser:password Usage:bbuild
# Ask the user to enter a password (does not echo what is typed)
#
# Echoes out the entered text
###/doc
function askuser:password {
    read -s -p "$* : " 1>&2
    echo "$REPLY"
}

### askuser:choose_multi Usage:bbuild
# Allows the user to choose from multiple choices
#
# askuser:chose_multi MESG CHOICESTRING
#
#
# MESG is a single string token that will be displayed as prompt
#
# CHOICESTRING is a comma-separated, or newline separated, or "\\n"-separated token string
#
# Equivalent strings include:
#
# * `"a\\nb\\nc"` - quoted and explicit newline escapes
# * `"a,b,c"` - quoted and separated with commas
# * `a , b , c` - not quoted, separated by commas
# * `a`, `b` and `c` on their own lines
#
# User input:
#
# User can choose by selecting
#
# * a single item by number
# * a range of numbers (4,7 for range 4 to 7)
# * or a string that matches the pattern
#
# All option lines that match will be returned, one per line
#
# If the user selects nothing, then function returns 1 and an empty stdout
###/doc
function askuser:choose_multi {
    local mesg=$1; shift || :
    local choices=$(echo "$*"|sed -r 's/ *, */\n/g')

    out:info "$mesg:" 
    local choicelist="$(echo -e "$choices"|egrep '^' -n| sed 's/:/: /')"
    echo "$choicelist" 1>&2
    
    local sel=$(askuser:ask "Choice")
    if [[ "$sel" =~ $blankpat ]]; then
        return 1

    elif [[ "$sel" =~ $numpat ]] || [[ "$sel" =~ $rangepat ]]; then
        echo -e "$choices" | sed -n "$sel p"
    
    elif [[ "$sel" =~ $listpat ]]; then
        echo "$choicelist" | egrep "^${sel// /|}:" | sed -r 's/^[0-9]+: //'

    else
        echo -e "$choices"  |egrep "$(echo "$sel"|tr " " '|')"
    fi
    return 0
}

### askuser:choose Usage:bbuild
# Ask the user to choose an item
#
# Like askuser:choose_multi, but will loop if the user selects more than one item
#
# If the user provides no entry, returns 1
#
# If the user chooses one item, that item is echoed to stdout
###/doc
function askuser:choose {
    local mesg=$1; shift || :
    while true; do
        local thechoice="$(askuser:choose_multi "$mesg" "$*")"
        local lines=$(echo -n "$thechoice" | grep '$' -c)
        if [[ $lines = 1 ]]; then
            echo "$thechoice"
            return 0
        elif [[ $lines = 0 ]]; then
            return 1
        else
            out:warn "Too many results"
        fi
    done
}
