#%include test.sh colours.sh

# Required for the pipe test
set -o pipefail

has_colour() {
    "$@"

    tty:is_pipe && echo "${CBRED}pipe detected${CDEF}"

    [[ -n "$CDEF" ]]
}

pipe_has_colour() {
    has_colour colours:auto | :
}

test:forbid has_colour colours:check --color=never

test:require has_colour colours:check --color=always

colours:auto
test:require has_colour : "colours:auto set before test"

test:forbid pipe_has_colour

test:require has_colour : "retained outside fo pipe"
