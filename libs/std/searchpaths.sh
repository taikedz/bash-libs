#%include std/out.sh

##bash-libs: searchpaths.sh @ %COMMITHASH%

# FIXME - set function signature in head of help
### searchpaths:file_from PATHDEF FILE Usage:bbuild
#
# Locate a file along a search path.
#
# EXAMPLE
#
# The following will look for each of the files
#  in order of preference of a local lib directory, a profile-wide one, then a system-
#  wide one.
#
#    MYPATH="./lib:$HOME/.local/lib:/usr/local/lib"
# 	searchpaths:file_from "$MYPATH" file
#
# Echoes the path of the first file found.
#
# Returns 1 on failure to find any file.
#
###/doc

function searchpaths:file_from {
    local PATHS="$1"; shift || :
    local FILE="$1"; shift || :

    local oldIFS="$IFS"
    IFS=$' \t\n'

    for path in $(echo "$PATHS"|tr ':' ' '); do
        local fpath="$path/$FILE"
        if [[ -f "$fpath" ]]; then
            echo "$fpath"
            return 0
        fi
    done

    IFS="$oldIFS"
    return 1
}
