##bash-libs: app/hovercraft.sh @ %COMMITHASH%

#%include std/syntax-extensions.sh
#%include std/bincheck.sh
#%include std/varify.sh

### hovercraft:serve MAINFILE Usage:bashdoc
# Build the presentation based on MAINFILE
#
# Opens a browser session with the presentation
###/doc

$%function hovercraft:serve(mainfile) {
    mkdir -p presentation-hovercraft
    local pdir="$(mktemp -d "presentation-hovercraft/$(varify:fil "$mainfile")-XXXX")"

    hovercraft "$mainfile" "$pdir"
    local runtime
    runtime="$(bincheck:get sensible-browser firefox chromium chrome gnome-www-browser epiphany x-www-browser www-browser)" || return 1

    "$runtime" "file://$PWD/$pdir/index.html"
}
