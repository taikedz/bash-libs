##bash-libs: app/pyvenv.sh @ %COMMITHASH%

#%include std/syntax-extensions.sh
#%include std/abspath.sh

BBUILD_PYTHONVENV=""

### pyvenv:setup DIRNAME [PYTHONVERSION] Usage:bbuild
# Create a virtual environment directory
#
# DIRNAME - the name of the directory to be a virtual environment
# PYTHONVERSION - version of python to use, uses virtualenv's default if not specified
###/doc
$%function pyvenv:setup(venvdir ?pyversion) {
    local useversion=(:)

    if [[ -n "$pyversion" ]]; then
        useversion+=(-p "$pyversion")
    fi

    virtualenv "${useversion[@]:1}" "$venvdir"
}

### pyvenv:ensure DIRNAME [PYTHONVERSION] Usage:bbuild
# Ensure a virtual environment directory is present; if not, create it.
#
# DIRNAME - the name of the directory to be a virtual environment
# PYTHONVERSION - version of python to use, uses virtualenv's default if not specified
###/doc
$%function pyvenv:ensure(venvdir ?pyversion) {
    if [[ ! -f "$venvdir/bin/activate" ]]; then
        pyvenv:setup "$venvdir" "$pyversion"
        pyvenv:activate "$venvdir"
        reqfile="$(dirname "$venvdir")/requirements.txt"
        if [[ -f "$reqfile" ]]; then
            pip install -r "$reqfile"
        fi
        pyvenv:deactivate
    fi
}

### pyvenv:activate DIRNAME Usage:bbuild
# Activate a virtual environment directory
#
# DIRNAME - the name of the virtual environment directory.
###/doc
$%function pyvenv:activate(venvdir) {
    if [[ -z "$BBUILD_PYTHONVENV" ]]; then
        PS1="${PS1:-}"
        . "$venvdir/bin/activate"
        BBUILD_PYTHONVENV="$(abspath:path "$venvdir")"
    else
        return 1
    fi
}

### pyvenv:deactivate Usage:bbuild
# Deactivate a virtual environment directory
###/doc
pyvenv:deactivate() {
    if [[ -n "$BBUILD_PYTHONVENV" ]]; then
        deactivate
        BBUILD_PYTHONVENV=false
    else
        return 1
    fi
}

### pyvenv:add LIBNAMES ... Usage:bbuild
# Add libraries to the virtual environment and save in a sidecar requirements.txt file
#
# returns: virtualenv code on failure, or
#
# 101 - virtualenv not activated through pyvenv:activate
###/doc
pyvenv:add() {
    if [[ -n "$BBUILD_PYTHONVENV" ]]; then
        pip install "$@" || return
        pip freeze > "$(dirname "$BBUILD_PYTHONVENV")/requirements.txt"
    else
        return 101
    fi
}
