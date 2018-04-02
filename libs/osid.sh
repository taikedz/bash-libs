##bash-libs: osid.sh @ %COMMITHASH%

### OS ID Usage:bbuild
#
# Identify the operating system
#
# Different distros provide information a bit differently.
# This library aims to provide that info in a unified API
#
###/doc

OSID_IDFILES=(/etc/os-release /etc/lsb-release)


### osid:load_id_file Usage:bbuild
#
# Attempt to load the ID file from a number of known locations.
#
###/doc
osid:load_id_file() {
	local file
	for file in "${OSID_FILES[@]}" ; do
		if [[ -f "$file" ]]; then
			. "$file"
			return 0
		fi
	done
	return 1
}

osid:__value() {
	if [[ -n "${1:-}" ]] ; then
		echo "$1"
		return 0
	fi
	return 1
}

### osid:name Usage:bbuild
# Get the distro's shortname
###/doc
osid:name() {
	osid:__value "${ID:-}" && return 0 || :
	osid:__value "${DISTRIB_ID:-}" && return 0 || :
	return 1
}


### osid:version Usage:bbuild
# Get the distro's version number
###/doc
osid:version() {
	osid:__value "${VERSION_ID:-}" && return 0 || :
	osid:__value "${DISTRIB_RELEASE:-}" && return 0 || :
	return 1
}


### osid:fullname Usage:bbuild
# Get the long version name of the distro
###/doc
osid:fullname() {
	osid:__value "${NAME:-}" && return 0 || :
	osid:__value "${DISTRIB_ID:-}" && return 0 || :
	return 1
}


### osid:nameversion Usage:bbuild
# Get the name-and-version string for the distro
###/doc
osid:nameversion() {
	osid:__value "${DISTRIB_DESCRIPTION:-}" && return 0 || :
	osid:__value "${PRETTY_NAME:-}" && return 0 || :
	return 1
}
