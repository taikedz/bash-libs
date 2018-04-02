### Insert file contents Usage:bbuild
# 
# insertfile LINE DESTFILE SOURCEFILE
#
# Inserts the contents of SOURCEFILE into DESTFILE after line LINENUM
#
# When LINENUM is 0, inserts the contents before any of the lines of the file.
#
###/doc

function insertfile {
	local line="$1"
	local destfile="$2"
	local sourcefile="$3"

	head -n "$line" "$destfile"
	cat "$sourcefile"
	tail -n +"$((line + 1))" "$destfile"
}
