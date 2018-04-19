#!/bin/bash

#%include tty.sh test.sh

inpipe() {
    "$@" | cat -
}

# `detect_pipe` and `test_ispipe`
# because of the way test.sh runs the tests (in a substitution shell, which counts as a pipe)
#   we need to run it outside of the test, and submit only the result itself to the test

detect_pipe() {
    tty:is_pipe
    INPIPE="$?"
}

test_ispipe() {
    if [[ -n "$INPIPE" ]]; then
        return "$INPIPE"
    else
        echo "detect_pipe was not run separately"
        return 1
    fi
}

detect_pipe
test:forbid test_ispipe
test:require inpipe tty:is_pipe

SSH_CLIENT=ok test:require tty:is_ssh
SSH_CONNECTION=ok test:require tty:is_ssh
SSH_TTY=ok test:require tty:is_ssh
SSHTTY= SSH_CLIENT= SSH_CONNECTION= test:forbid tty:is_ssh

test:report
