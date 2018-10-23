##bash-libs: git.sh @ %COMMITHASH%

### Git handlers Usage:bbuild
#
# Some handler functions wrapping git, for automation scripts that pull/update git repositories.
#
###/doc

### git:ensure URL [DIRPATH] Usage:bbuild
#
# Clone a repository, optionally to a directory path or ./<reponame> when none specified
#
# If a repository already exists here, check that the URL matches at least one remote,
#   if so, update
#   if not, return error
#
# Error codes used
# 10 - no URL
# 11 - directory exists, and is not a git repo
# 12 - directory exists, but the specified URL was not among the remotes
#
###/doc

git:clone() {
    local url dirpath reponame
    url="${1:-}"; shift || :
    [[ -n "$url" ]] || return 10

    reponame="$(basename "$url")"
    reponame="${reponame%*.git}"

    dirpath="${1:-./$reponame}"

    [[ -d "$dirpath" ]] || {
        git clone "$url" "$dirpath"
        return "$?"
    }

    [[ -d "$dirpath/.git" ]] || {
        return 11
    }

    ( cd "$dirpath" ; git remote -v | grep "$url" -q ) || {
        return 12
    }

    ( cd "$dirpath" ; git:update master )
}

### git:update [BRANCH [REMOTE] ] Usage:bbuild
#
# Check out a branch (default master), stashing if needed, and pull the latest changes from remote (default origin)
#
# 10 - Untracked files present; cannot stash, cannot pull
# 11 - stash failed
# 12 - no remotes
#
###/doc

git:update() {
    local status_string branch remote

    branch="${1:-master}"; shift || :
    remote="${1:-origin}"; shift || :

    [[ $(git remote -v | wc -l | cut -d' ' -f2) -gt 0 ]] || return 12

    status_string="$(git status)"
    if ! ( echo "$status_string" | grep "working tree clean" -iq ) ; then
        if echo "$status_string" | grep -e "^Untracked files:" -q ; then return 10 ; fi

        git stash || return 11
    fi

    git pull "$remote" "$branch" || return 12
}

### git:last-tagged-version Usage:bbuild
#
# Look through history of the current branch and find the latest version tag
#
# If a version is found, that version is echoed, with a prefix:
#
# * "=" if the current commit is tagged with the latest version found
# * ">" if the current commit is later than the latest version found
#
# If no version is found, returns with status 1
#
###/doc

git:last-tagged-version() {
    git:get-repo >/dev/null || return 1

    local tagpat='(?<=tag: )([vV]\.?)?[0-9.]+'
    local tagged_version
    tagged_version="$(git log --oneline -n 1 --format="%d" | grep -oP "$tagpat")" || :

    if [[ -z "$tagged_version" ]]; then
        tagged_version="$(git log --format="%d"|grep -vP '^\s*$' | grep -oP "$tagpat" -m 1)" || :
        if [[ -z "$tagged_version" ]]; then
            return 1
        fi

        tagged_version=">$tagged_version"
    else
        tagged_version="=$tagged_version"
    fi

    echo "$tagged_version"
}

git:get-repo() {
    local path="$PWD"

    while [[ "$path" != / ]] && [[ ! -d "$path/.git" ]]; do
        path="$(cd "$path/.."; pwd)"
    done

    if [[ "$path" = "/" ]]; then
        return 1
    else
        echo "$path"
    fi
}
