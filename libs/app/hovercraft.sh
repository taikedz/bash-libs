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

### hovercraft:serve MAINFILE [BROWSER] Usage:bbuild
# Build the presentation based on MAINFILE ;
#
# Opens a browser session with the presentation.
#
# If browser is not specified, attempts to use the default system browser.
###/doc

$%function hovercraft:serve(mainfile ?browser) {
    local presentation="file://$PWD/$(hovercraft:build "$mainfile")"

    if [[ -z "$browser" ]]; then
        webbrowser:visit "$presentation"
    else
        "$browser" "$presentation"
    fi
}
