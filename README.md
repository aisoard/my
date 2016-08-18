my
==

Shell scripts to easily manage PATH-like environment variables


USAGE
-----

In your shell:

    $ my program
    Added '/home/user/.opt/program/bin' to PATH
    Added '/home/user/.opt/program/lib' to PATH

INSTALL
-------

Create a `.opt` directory into your home directory.

Create a subdirectory in `~/.opt` for each user program you want to easily manage.


### Bash

Add `source /path/to/my.sh` in your `.bashrc`, `.bash_profile` or `.profile`.

You can also add additional search directories:
    MY_SEARCH_DIR="$MY_SEARCH_DIR /other/search/path"


TIPS
----

When compiling, set `--prefix=$HOME/.opt/progname` (for `configure` or `setup.py`)
or `-DCMAKE_INSTALL_PREFIX:STRING=$HOME/.opt/progname` (for `cmake`) and install the program.
This usually correctly setup the directory, ready to be used by `my`.