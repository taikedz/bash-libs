##bash-libs: app/webbrowser.sh @ %COMMITHASH%

### webbrowser Usage:bbuild
# Library to control web browsers
###/doc

#%include std/syntax-extensions.sh
#%include std/bincheck.sh

### webbrowser:visit URL Usage:bbuild
# Visit a URL in a graphical web broswer.
#
# Will try to get the system's web browser, or try to locate any one of a wide selection of browsers.
###/doc
$%function webbrowser:visit(url) {
    local runtime

    local browser_options=(
        sensible-browser # Ubuntu's shorthand for the system browser
        gnome-www-browser # Gnome's shorthand
        firefox opera chromium epiphany # popular browsers by bin name
        x-www-browser www-browser # System terminal-based browsers
        elinks
    )
    runtime="$(bincheck:get "${browser_options[@]}")" || return 1

    if [[ -z "$runtime" ]]; then
        "$runtime" "$url"
        return
    fi
    return 127
}
