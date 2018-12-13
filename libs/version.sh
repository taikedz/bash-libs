#%include syntax-extensions.sh

##bash-libs: version.sh @ %COMMITHASH%

### Version Tool Usage:bbuild
#
# Functions for handling version numbers.
#
# We assume sem-ver versioning, consisting of
#
# 	x.y.z
#
# where `x` is more significant than `y`, more significant in turn than `z`
#
# All parts must be present. If comparing a version string "2.3", write it as "2.3.0"
#
###/doc

### version:gt VERSIONSTRING1 VERSIONSTRING2 Usage:bbuild
#
# Returns 0 if VERSIONSTRING1 is strictly greater than VERSIONSTRING2
#
###/doc

version:gt() {
    local version1="$1"; shift || :
    local version2="$1"; shift || :

    version1="$(version:validate "$version1")" || return 1
    version2="$(version:validate "$version2")" || return 1

    read v1x v1y v1z < <(echo "$version1"|sed 's/\./ /g')
    read v2x v2y v2z < <(echo "$version2"|sed 's/\./ /g')

    # if lesser fail, if greater succeed, if equal, check minor
    [[ "$v1x" -gt "$v2x" ]] && return 0 || :
    [[ "$v1x" -lt "$v2x" ]] && return 1 || :

    [[ "$v1y" -gt "$v2y" ]] && return 0 || :
    [[ "$v1y" -lt "$v2y" ]] && return 1 || :

    # At this point, equality of the patch version is also a disqualifier.
    [[ "$v1z" -gt "$v2z" ]] && return 0 || :
    [[ "$v1z" -le "$v2z" ]] && return 1 || :

}

### version:next {major|minor|patch} VERSIONSTRING Usage:bbuild
#
# Bump the relevant version number.
#
###/doc

version:next() {
    local vsection="$1"; shift || :
    local sversion="$1"; shift || :

    version="$(version:validate "$sversion")" || return 1

    read vx vy vz < <(echo "$sversion"|sed 's/\./ /g')

    case "$vsection" in
    major)
        vx=$((vx+1))
        vy=0
        vz=0
        ;;
    minor)
        vy=$((vy+1))
        vz=0
        ;;
    patch)
        vz=$((vz+1)) ;;
    *)
        return 1
        ;;
    esac

    echo "${vx}.${vy}.${vz}"
    return 0
}

$%function version:validate(version) {
    if [[ "$version" =~ ^[0-9]+$ ]]; then
        echo "${version}.0.0"

    elif [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo "${version}.0"

    elif [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$version"

    else
        return 1
    fi
}
