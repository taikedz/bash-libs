#!/bin/bash

### Useful patterns Usage:bbuild
#
# Some useful regex patterns, exported as environment variables.
#
# They are not foolproof, and you are encouraged to improve upon them.
#
# PAT_blank - detects whether an entire line is empty or whitespace
# PAT_comment - detects whether is a line is a script comment (assumes '#' as the comment marker)
# PAT_num - detects whether the string is an integer number in its entirety
# PAT_cvar - detects if the string is a valid C variable name
# PAT_filename - detects if the string is a safe UNIX or Windows file name;
#   does not allow presence of whitespace or special characters aside from '_', '.', '-'
# PAT_email - simple heuristic to determine whether a string looks like a valid email address
#
###/doc

export PAT_blank='^\s*$'
export PAT_comment='^\s*(#.*)?$'
export PAT_num='^[0-9]+$'
export PAT_cvar='^[a-zA-Z_][a-zA-Z0-9_]*$'
export PAT_filename='^[a-zA-Z0-9_.-]$'
export PAT_email="$PAT_filename@$PAT_filename.$PAT_cvar"
