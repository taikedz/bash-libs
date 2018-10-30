#%include out.sh
#%include bincheck.sh
#%include args.sh

### tmux.sh Usage:bbuild
# 
# Help run commands in tmux session. Useful for performing operations over remote connections.
#
# Error codes:
#   TMUX_ERR_in_session - session is currently in tmux
#   TMUX_ERR_run_failed - an attempt to run tmux failed
#       
###/doc

TMUX_ERR_in_session=1
TMUX_ERR_run_failed=2
TMUX_ERR_not_available=3

### tmux:run COMMAND ... Usage:bbuild
#
# Run the command in a tmux session.
#
# Returns 0 if a new tmux session was created to run the script.
#
# Returns `$TMUX_ERR_in_session` if currently in a screen/tmux session already
#
# Retuns `$TMUX_ERR_run_failed` otherwise.
#
# Returns `$TMUX_ERR_not_available` if 'tmux' is not available.
#
# Example:
#
#   main() {
#     if tmux:run "$0" "$@"; then
#       exit 0
#     fi
#
#     apt-get update
#     apt-get install "$@"
#   }
#
#   main "$@"
#
###/doc
tmux:run() {
    tmux:available || return "$TMUX_ERR_not_available"

    if tmux:in-session; then
        return $TMUX_ERR_in_session
    fi

    tmux new bash "$@" || return $TMUX_ERR_run_failed
}

### tmux:ensure COMMAND ... Usage:bbuild
#
# Run `COMMAND ...` in tmux
#
# Exits shell with status 0 if successfully started in tmux (do not proceed with rest of script)
#
# Returns 0 if already in session (proceed with rest of script)
#
# Returns `$TMUX_ERR_not_available` if tmux is not available
#
# Returns `$TMUX_ERR_run_failed` otherwise
#
# Example:
#
#   main() {
#     tmux:ensure "$0" "$@"
#
#     apt-get update
#     apt-get install "$@"
#   }
#
#   main "$@"
#
###/doc
tmux:ensure() {
    if tmux:in-session; then
        return 0
    fi

    if tmux:run "$@"; then
        exit 0
    fi
    
    return "$TMUX_ERR_run_failed"
}

### tmux:in-session Usage:bbuild
# Whether current session is running in tmux (or screen)
###/doc
tmux:in-session() {
    [[ "$TERM" = screen ]] || return $TMUX_ERR_in_session
}

### tmux:available Usage:bbuild
# Whether the tmux command is available
#
# Returns 0 if command is available
# Returns 1 if command is not available
###/doc
tmux:available() {
    bincheck:has tmux
}
