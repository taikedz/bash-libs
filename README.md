# Bash Builder Standard Library Collection

`libs/` contains a collection of bash functions and definitions for inclusion in scripts using your bash scripts.

See [`bash-builder`](https://github.com/taikedz/bash-builder) for more information.

## Note on pre-2.0 library installations

Older versions of `bash-libs` installed directly to a `.../lib/bbuild` directory. From 2.0 upwards, libraries will be installed to `.../lib/bbuild/bb` ; scripts using Bash Builder will need to change their import statements, or add the new location to their path.

The recommended action is to update the inclusion statements of your scripts:

    #%include out.sh
    #%include args.sh

becomes

    #%include bb/out.sh
    #%include bb/args.sh

This is being done so that other library collections can be added to `.../lib/bbuild` directory, whilst still allowing the standard `bbuild/bb/` directory to be purged by the installer.

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
