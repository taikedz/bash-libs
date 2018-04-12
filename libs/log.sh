##bash-libs: log.sh @ %COMMITHASH%

#%include args.sh

### Logging facility Usage:bbuild
#
# By default, writes to <stderr>
#
# Precedes all messages with the name of the script
#
# If you specify a log file with log:use_cwd or log:use_file then the log info
#  is written to the appropriate file, and not to stderr
#
# Example usage:
#
# 	log:use_file activity.log
#
# 	log:info "This is an info message"
#
###/doc

BBLOGFILE=/dev/stderr
LOGENTITY=$(basename "$0")

### LOG_LEVEL Usage:bbuild
#
# Log level environment variable, by default set to WARN level.
#
# Set it to one of the predefined values:
#
# $LOG_LEVEL_FAIL - failures only
# $LOG_LEVEL_WARN - failures and warnings
# $LOG_LEVEL_INFO - failures, warnings and information
# $LOG_LEVEL_DEBUG - failures, warnings, info and debug
#
# Example:
#
# 	export LOG_LEVEL=$LOG_LEVEL_INFO
# 	command ...
#
###/doc

LOG_LEVEL=1

LOG_LEVEL_FAIL=0
LOG_LEVEL_WARN=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3

# Handily determine that the minimal level threshold is met
function log:islevel {
    local req_level="$1"; shift || :

    [[ "$LOG_LEVEL" -ge "$req_level" ]]
}

### log:get_level ARGS ... Usage:bbuild
#
# Pass script arguments and check for log level modifier
#
# This function will look for an argument like --log=N or --log={fail|warn|info|debug} and set the level appropriately
#
# Retuns non-zero if log level was specified but could not be determined
#
# Usage example:
#
# 	main() {
# 		log:get_level "$@" || echo "Invalid log level"
#
# 		# ... your code ...
# 	}
#
# 	main "$@"
#
###/doc

function log:get_level {
    local level="$(args:get --log "$@")"

    if [[ -z "$level" ]]; then
        return 0
    fi

    case "$level" in
    0|fail)
        LOG_LEVEL="$LOG_LEVEL_FAIL" ;;
    1|warn)
        LOG_LEVEL="$LOG_LEVEL_WARN" ;;
    2|info)
        LOG_LEVEL="$LOG_LEVEL_INFO" ;;
    3|debug)
        LOG_LEVEL="$LOG_LEVEL_DEBUG" ;;
    *)
        return 1
    esac

    return 0
}

### log:use_file LOGFILE Usage:bbuild
# Set the specified file as log file.
#
# If this fails, log is sent to stderr and code 1 is returned
###/doc
function log:use_file {
    local target_file="$1"; shift || :
    local standard_outputs="/dev/(stdout|stderr)"
    local res=0

    if [[ ! "$target_file" =~ $standard_outputs ]]; then

        echo "$LOGENTITY $(date +"%F %T") Selecting log file" >> "$target_file" || {
            res=1
            local msg="Could not set the log file to [$target_file] ; moving to stderr"

            if [[ "$BBLOGFILE" != /dev/stderr ]]; then
                # leave a trace of this in the last log file
                log:warn "$msg" || :
            fi

            export BBLOGFILE=/dev/stderr
            log:warn "$msg"
        }
    fi
    export BBLOGFILE="$target_file"
    return $res
}

### log:use_cwd Usage:bbuild
# Create a log file in the current working directory, using the current script's name
#  as a base for the log file's name
#
# If could not log in a local file, falls back to stderr and returns code 1
###/doc
function log:use_cwd {
    log:use_file "$PWD/$LOGENTITY.log"
    return "$?"
}

### log:use_var Usage:bbuild
# Set the log location to /var/log/<SCRIPTNAME>/...
#
# prints the log file in use to stderr
#
# If /var/log location cannot be accessed, tries to log to current directory
#
# If current location cannot be logged to, writes to stderr
#
# Returns code 1 if location in /var/log could not be used
###/doc
function log:use_var {
    local logdir="/var/log/$LOGENTITY"
    local logfile="$(whoami)-$UID-$HOSTNAME.log"
    local tgtlog="$logdir/$logfile"

    (mkdir -p "$logdir" && touch "$tgtlog") || {
        out:warn "Could not create [$logfile] in [$logdir] - logging locally"
        log:use_cwd
        return 1
    }

    log:use_file "$tgtlog"
}

### log:debug MESSAGE Usage:bbuild
# Print a debug message to the log
###/doc
function log:debug {
    log:islevel "$LOG_LEVEL_DEBUG" || return 0

    if [[ "$MODE_DEBUG" = yes ]]; then
        echo -e "$LOGENTITY $(date "+%F %T") DEBUG: $*" >>"$BBLOGFILE"
    fi
}

### log:debug:fork [MARKER] Usage:bbuild
#
# Pipe the data coming through stdin to stdout
#
# *Also* write the same data to the log when at debug level, each line preceded by MARKER
#
# Insert this debug fork into pipes to record their output
#
###/doc
function log:debug:fork {
    if log:islevel "$LOG_LEVEL_DEBUG"; then
        local MARKER="${1:-PIPEDUMP}"; shift || :
        MARKER="$(date "+%F %T") $MARKER :"

        cat - | sed -r "s/^/$MARKER/" | tee -a "$BBLOGFILE"
    else
        cat -
    fi
}

### log:info MESSAGE Usage:bbuild
# print an informational message to the log
###/doc
function log:info {
    log:islevel "$LOG_LEVEL_INFO" || return 0

    echo -e "$LOGENTITY $(date "+%F %T") INFO: $*" >>"$BBLOGFILE"
}

### log:warn MESSAGE Usage:bbuild
# print a warning message to the log
###/doc
function log:warn {
    log:islevel "$LOG_LEVEL_WARN" || return 0

    echo -e "$LOGENTITY $(date "+%F %T") WARN: $*" >>"$BBLOGFILE"
}

### log:fail [CODE] MESSAGE Usage:bbuild
# print a failure-level message to the log
###/doc
function log:fail {
    log:islevel "$LOG_LEVEL_FAIL" || return 0

    echo "$LOGENTITY $(date "+%F %T") FAIL: $*" >>"$BBLOGFILE"
}

### log:dump Usage:bbuild
#
# Dump the stdin to the log.
#
# Requires level $LOG_LEVEL_DEBUG
#
# Example:
#
# 	action_command 2>&1 | log:dump
#
###/doc

function log:dump {
    log:debug "$* -------------¬"
    log:debug "$(cat -)"
    log:debug "______________/"
}
