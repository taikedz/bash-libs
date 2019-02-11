##bash-libs: ensureline.sh @ %COMMITHASH%

### ensureline Usage:bbuild
#
# Utility for manipulating config files (and other files where all similar lines need to match).
#
#    ensureline FILE PATTERN LINEDATA
#
# Ensure that **every** line in FILE matched by PATTERN becomes LINEDATA
#
# If no such line is found, LINEDATA is appended to the end of the file.
#
# For example
#
# 	ensureline /etc/ssh/sshd_config '#?PasswordAuthentication.*' "PasswordAuthentication no"
#
# Ensure that the PasswordAuthentication line, whether commented out or not,
# becomes an uncomented "PasswordAuthentication no", or add it to the end of the file.
#
# The match applies to the full line; the pattern '#?PasswordAuth' on its own would not match, due to the missing characters.
#
###/doc

function ensureline {
    local file="$1"; shift || :
    local pattern="$1"; shift || :

    if grep -P "^$pattern$" "$file" -q ; then
        ensureline:matches "$file" "$pattern" "$@"
    else
        ensureline:add "$file" "$pattern" "$@"
    fi
}

# The following functions are internal, and should not be used.
# Use the main `ensureline` instead

function ensureline:matches {
    local FILE="$1"; shift || :
    local PATTERN="$1"; shift || :
    local LINEDATA="$1"; shift || :

    #TODO - add support to specify a start line, and a range?

    sed -r "s^$PATTERN$$LINEDATA" -i "$FILE"
}

function ensureline:add {
    local FILE="$1"; shift || :
    local PATTERN="$1"; shift || :
    local LINEDATA="$1"; shift || :

    echo "$LINEDATA" >> "$FILE"
}
