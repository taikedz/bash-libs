##bash-libs: installtk.sh @ %COMMITHASH%

### Installation script tooklit Usage:bbuild
#
# Basic toolkit for creating an installer for your scripts.
#
# Assuming your project name is `my-project` and you have assets in a `scripts/`
# directory, and you want to install a `runit` command pointing at your
# `scripts/main.sh` script, you can write the following install script:
#
#    #%include installth.sh
#
#    installtk:set-name my-project
#
#    installtk:allow-non-root # optional
#
#    installtk:install-assets scripts
#    installtk:add-command runit scripts/main.sh
#
###/doc

#%include out.sh isroot.sh

installtk:set-name() {
    INSTALLTK_project_name="$1"
}

installtk:has_name() {
    [[ -n "${INSTALLTK_project_name:-}" ]] || out:fail "installtk : Project name not set"
}

installtk:allow-non-root() {
    INSTALLTK_need_root=false
}

installtk:_setup_dirs() {
    BINDIR="$HOME/.local/bin"
    LIBSDIR="$HOME/.local/lib/$INSTALLTK_project_name"
    if ! isroot; then
        BINDIR=/usr/bin
        LIBSDIR=/usr/lib/"$INSTALLTK_project_name"
    fi

    [[ -d "$BINDIR" ]]  || mkdir -p "$BINDIR"
    [[ -d "$LIBSDIR" ]] || mkdir -p "$LIBSDIR"
}

installtk:_require_root() {
    if [[ "${INSTALLTK_need_root:-}" = false ]]; then
        return 0
    fi
    isroot:require "You must be root to run this script."
}

installtk:install-assets() {
    local asset

    installtk:has_name
    installtk:_setup_dirs

    for asset in "$@"; do
        out:info "Installing $asset to $LIBSDIR"
        rsync -a "$asset/" "$LIBSDIR/$asset/"
    done
}

installtk:_asset_dir() {
    local basedir
    basedir="$(dirname "$1")"

    if [[ "$basedir" =~ (^\s*|/)\.\.(\s*$|/) ]]; then
        out:fail "installtk : relative path found in '$1' - abort"
    else
        echo "$basedir"
    fi
}

installtk:add-command() {
    local scriptpath

    installtk:has_name
    installtk:_setup_dirs

    # Allows bash scripts to source 
    scriptpath="$(installtk:_asset_dir "$LIBSDIR/$2")"

    chmod 755 "$BINDIR/$1"
    echo -e "#!/usr/bin/env bash\nPATH=\"$scriptpath:\$PATH\" \"$LIBSDIR/$2\" \"\$@\"" > "$BINDIR/$1"
}
