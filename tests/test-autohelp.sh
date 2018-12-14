#%include std/test.sh
#%include std/autohelp.sh

### Test-help Usage:help
#
# ### Quoted-help-content Usage:bbuild
# #
# ###/doc
#
# Real-content
#
###/doc

### Test-bbuild Usage:bbuild
# Some actual bbuild help
###/doc

helpfor() {
    local expect="$1"; shift

    local result
    result="$(set -euo pipefail; "$@")" || return

    echo "$result"|grep "$expect"
}

test:require helpfor Test-help           autohelp:print help
test:require helpfor Real-content        autohelp:print help
test:require helpfor Quoted-help-content autohelp:print help
test:forbid  helpfor Test-bbuild         autohelp:print help

test:require helpfor Test-bbuild          autohelp:print bbuild
test:require helpfor "actual bbuild help" autohelp:print bbuild
test:forbid  helpfor Quoted-help          autohelp:print bbuild

test:require helpfor Test-help           autohelp:check one --help two
test:require helpfor Test-help           autohelp:check-or-null
test:forbid  helpfor Test-help           autohelp:check one two

test:require helpfor dummy     autohelp:print help <(echo -e "### dummy Usage:help\n###/doc")

test:report
