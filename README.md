# Bash Builder Standard Library Collection

`libs/` contains a collection of bash functions and definitions for inclusion in scripts using your bash scripts.

See [`bash-builder`](https://github.com/taikedz/bash-builder) for more information.

## Verifying

You need to have installed bash-builder to run verification of scripts; or, run the following to use the bootstrap version

	git clone https://github.com/taikedz/bash-builder
	export BBEXEC="$PWD/bash-builder/bootstrap/bootstrap-bbuild5"

To test the build of all libraries and run unit tests, run:

	./verify.sh

### Additional run modes

You need `shellcheck` to run static analysis checks.

Specify libraries explicitly:

	./verify.sh libs/args.sh libs/out.sh

You can deactivate unit tests:

	runtests=false ./verify

Run shellcheck after building a library (pass flags to `bbuild`):

	bbflags=-c ./verify

Compile the `version.sh` library and shellcheck it, without its tests:

	bbflags=-c runtests=false ./verify libs/version.sh

Any combination of the above should be possible.
