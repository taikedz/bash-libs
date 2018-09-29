##bash-libs: safe.sh @ %COMMITHASH%

### Safe mode Usage:bbuild
#
# Set safe mode options
#
# * Script bails on error
# * Accessing a variable that is not set is an error
# * If a file glob does not expand, cause an error condition
# * If a component of a pipe fails, the entire pipe is a failure
#
###/doc

set -eufo pipefail

# TODO for future use - not to be activated until all libs have been checked
# (all "$@" and ( <array> ) uses)
#IFS='\t\n'
