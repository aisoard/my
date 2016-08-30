my
==

Shell scripts to easily manage PATH-like environment variables


USAGE
-----

In your shell:

    $ my program
    Added '/home/user/.opt/program/bin' to PATH
    Added '/home/user/.opt/program/lib' to LD_LIBRARY_PATH
    Added '/home/user/.opt/program/lib' to LIBRARY_PATH
    Added '/home/user/.opt/program/lib/python2.7/site-packages' to PYTHONPATH
    Added '/home/user/.opt/program/include' to CPATH
    Added '/home/user/.opt/program/share/man' to MANPATH

INSTALL
-------

Create a `~/.opt` directory into your home directory and clone this repository as `~/.opt/my`.
Similarly, create a subdirectory in `~/.opt` for each user program you want to easily manage.


### Bash

Add `source ~/.opt/my.sh` in your `.bashrc`, `.bash_profile` or `.profile`.

You can add additional search directories:

    MY_SEARCH_DIRS="$MY_SEARCH_DIRS /other/search/path"


TIPS
----

When compiling a program, set `--prefix=$HOME/.opt/progname` (for `configure` or `setup.py`)
or `-DCMAKE_INSTALL_PREFIX:STRING=$HOME/.opt/progname` (for `cmake`) when configuring,
then compile and install the program.

This usually correctly setup the directory, ready to be used by `my`.
