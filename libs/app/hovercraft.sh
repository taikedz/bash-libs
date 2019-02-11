##bash-libs: app/hovercraft.sh @ %COMMITHASH%

#%include std/syntax-extensions.sh
#%include std/varify.sh

#%include app/webbrowser.sh

### hovercraft:serve MAINFILE Usage:bashdoc
# Build the presentation based on MAINFILE
#
# Opens a browser session with the presentation
###/doc

$%function hovercraft:serve(mainfile) {
    mkdir -p presentation-hovercraft
    local pdir="$(mktemp -d "presentation-hovercraft/$(varify:fil "$mainfile")-XXXX")"

    hovercraft "$mainfile" "$pdir"
    browser:visit "file://$PWD/$pdir/index.html"
}
