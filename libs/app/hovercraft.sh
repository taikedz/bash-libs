##bash-libs: app/hovercraft.sh @ %COMMITHASH%

#%include std/syntax-extensions.sh
#%include std/varify.sh

#%include app/webbrowser.sh

### hovercraft:build MAINFILE Usage:bbuild
# Build the presentation from the MAINFILE (.rst file), and print the path of the compiled presentation
###/doc

$%function hovercraft:build(mainfile) {
    mkdir -p presentation-hovercraft
    local pdir="$(mktemp -d "presentation-hovercraft/$(varify:fil "$mainfile")-XXXX")"

    hovercraft "$mainfile" "$pdir"

    echo "$pdir/index.html"
}

### hovercraft:show MAINFILE [BROWSER] Usage:bbuild
# Build the presentation based on MAINFILE ;
#
# Opens a browser session with the presentation.
#
# If browser is not specified, attempts to use the default system browser.
###/doc

$%function hovercraft:show(mainfile ?browser) {
    local presentation="file://$PWD/$(hovercraft:build "$mainfile")"

    if [[ -z "$browser" ]]; then
        webbrowser:visit "$presentation"
    else
        "$browser" "$presentation"
    fi
}

### hovercraft:serve MAINFILE [COMMAND ...] Usage:bbuild
# Build the presentation base on MAINFILE ;
#
# Use the specified command to serve the presentation through a web server.
#
# By default, the command is `python3 -m http.server 8090`
# run in the context of the built presentation's directory
###/doc

$%function hovercraft:serve(mainfile) {
    local presentation_file="$(hovercraft:build "$mainfile")"
    local presentation_dir="$(dirname "$presentation_file")"

    cd "$presentation_dir"

    if [[ -z "$*" ]]; then
        python3 -m http.server 8090
    else
        "$@"
    fi
}
