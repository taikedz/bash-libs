# Bash Builder Standard Library Collection

`std/` contains a collection of bash functions and definitions for inclusion in scripts using your bash scripts, as a "standard library" for Bash Builder.

See [`bash-builder`](https://github.com/taikedz/bash-builder) for more information.

## Verifying

To test the build of all libraries and run unit tests using your installed `bash-builder`, just run:

	./verify.sh

If you have not yet installed `bash-builder`, you need to do the following to run the verification tests:

	git clone https://github.com/taikedz/bash-builder
	export BBEXEC="$PWD/bash-builder/bin/bbuild"

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

## Note on pre-2.0 library installations

Older versions of `bash-libs` installed directly to a `.../lib/bbuild` directory. From 2.0 upwards, libraries will be installed to `.../lib/bash-builder/std` ; scripts using Bash Builder will need to change their import statements, or add the new location to their path.

The recommended action is to update the inclusion statements of your scripts:

    #%include out.sh
    #%include args.sh

becomes

    #%include std/out.sh
    #%include std/args.sh

This is being done so that other library collections can be added to `.../lib/bbuild` directory, whilst still allowing the standard `bbuild/std/` directory to be purged by the installer.

If you previously had an installation of `bash builder` you will need to edit your `BBPATH` to point to the new paths:

    export BBPATH="$HOME/.local/lib/bash-builder:/usr/local/lib/bash-builder"
