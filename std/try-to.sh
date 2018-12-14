#%include std/askuser.sh

##bash-libs: try-to.sh @ %COMMITHASH%

### try-to COMMAND ... Usage:bbuild
# Try to run something, offer the user an opportunity to resolve problems and retry
###/doc

try-to() {
    local result
    echo -e "\033[31;1m$*\033[0m"
    while ! (set -e; "$@"); do
        

        if ! askuser:confirm "Retry (y) or continue (n)? (Ctrl-C to abort script)"; then
            return 1
        fi
    done
}

