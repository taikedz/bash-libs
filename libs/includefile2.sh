##bash-libs: includefile2.sh @ %COMMITHASH%

### File Inclusion Usage:bbuild
# Library for including (once) or inserting (any time called) external files ontents
# based on developer-defined tokens
##/doc

#%include searchpaths.sh out.sh

includefile:reset_tracker() {
	INCLUDEFILE_tracker=""
}

### includefile:process TARGET Usage:bbuild
# Perform inclusions on stated target file
#
# Writes fully included result to stdout
#
# set INCLUDEFILE_token string to define the token which, at the begining of a line
#  declares a list of files to include
# set INCLUDEFILE_paths colon-delimited string to a search pth from which to find scripts to source
###/doc
includefile:process() {
	local target
	local workfile
	local dumpfile
	target="$1"; shift
	workfile="$(mktemp ./._include-XXXX)"
	dumpfile="$(mktemp ./._include-d-XXXX)"

	trap "includefile:cleanup" SIGINT EXIT

	: ${INCLUDEFILE_paths=./}
	: ${INCLUDEFILE_token=@include}

	includefile:reset_tracker
	
	cat "$target" > "$workfile"
	
	while includefile:_has_inclusion_line "$workfile"; do
		includefile:_process_first_inclusion "$workfile" > "$dumpfile" || return 1
		cat "$dumpfile" > "$workfile"
	done

	cat "$workfile"
}

### includefile:_process_first_inclusion TARGET Usage:internal
# Find the first onclusion line, and include its targets
#
# returns 0 on successful inclusions
# returns 1 on issues with inclusions
###/doc
includefile:_process_first_inclusion() {
	local fd_target="$1"; shift
	local target="$(mktemp)"
	cat "$fd_target" > "$target"

	local pos=$(includefile:_get_inclusion_line_pos "$target")
	local inctokens=($(includefile:_get_inclusion_line_string "$target"))

	head -n $((pos - 1)) "$target"
	includefile:_cat_once "${inctokens[@]:1}" || return 1
	tail -n +$((pos + 1)) "$target"

	rm "$target"

	return 0
}

includefile:_get_inclusion_line_pos() {
	local targetfile="$1"; shift

	grep -nP "^$INCLUDEFILE_token" "$targetfile" | head -n 1 | cut -d: -f1
}

includefile:_get_inclusion_line_string() {
	local targetfile="$1"; shift

	grep -P "^$INCLUDEFILE_token" "$targetfile" | head -n 1 
}

includefile:_has_inclusion_line() {
	local targetfile="$1"; shift

	grep -qP "^$INCLUDEFILE_token" "$targetfile"
}

includefile:_cat_once() {
	local item
	local fullpath
	local b64t
	for item in "$@"; do
		[[ -n "$item" ]] || continue

		fullpath="$(searchpaths:file_from "$INCLUDEFILE_paths" "$item")"
		if [[ -z "$fullpath" ]]; then
			INCLUDEFILE_failed="$item"
			return 1
		fi
		
		out:debug "$item => $fullpath"
		b64t=";$(echo "$fullpath" | base64 -w 0);"
		if [[  "$INCLUDEFILE_tracker" =~ "$b64t" ]]; then
			out:debug "\033[33;1m    Skip re-inclusion of [$item] (is in '$INCLUDEFILE_tracker')"
			continue
		fi

		export INCLUDEFILE_tracker="$INCLUDEFILE_tracker $b64t"
		cat "$fullpath"
	done
}

includefile:cleanup() {
	rm ./._include-*
}
