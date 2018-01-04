#!/bin/bash

cd "$(dirname "$0")"

if [[ "$UID" == 0 ]]; then
	: ${libs=/usr/local/lib/bbuild}
else
	: ${libs="$HOME/.local/lib/bbuild"}
fi

mkdir -p "$libs"

cp libs/*.sh "$libs/"
if [[ "$UID" = 0 ]]; then
	chmod 644 "$libs"/*
fi

echo -e "\033[32;1mSuccessfully installed libraries to [$libs]\033[0m"
