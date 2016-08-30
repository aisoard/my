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
Example, for `git` you would have a `~/.opt/git` directory containing a `bin` and `lib`
directory. The tree would look something like:

    $ tree ~/.opt
    ├── .opt/my
    │   ├── bin
    │   │   ├── python
    │   │   ├── python2 -> python
    │   │   ├── python2.0 -> python2
    │   │   ├── ...
    │   │   ├── python2.7 -> python2
    │   │   ├── python3 -> python
    │   │   ├── python3.0 -> python3
    │   │   ├── ...
    │   │   └── python3.5 -> python3
    │   ├── my.sh
    │   └── README.md
    ├── .opt/git
    │   ├── bin
    │   │   ├── git
    │   │   └── ...
    │   ├── lib
    │   │   └── ...
    │   ├── lib64
    │   │   └── ...
    │   ├── libexec
    │   │   └── ...
    │   └── share
    │       ├── locale
    │       │   └── ...
    │       └── man
    │           └── ...
    ...

Then, the following, depending on your shell.

### Bash

Add `source ~/.opt/my.sh` in your `.bashrc`, `.bash_profile` or `.profile`.

By default `my` will look into `~/.opt` and `/opt` directories, you can change
that by adding additional search directories to `MY_SEARCH_DIRS`:

    source ~/.opt/my/.sh
    MY_SEARCH_DIRS="$MY_SEARCH_DIRS /other/search/path"


TIPS
----

When compiling a program, set `--prefix=$HOME/.opt/progname` (when using `configure` or `setup.py`)
or `-DCMAKE_INSTALL_PREFIX:STRING=$HOME/.opt/progname` (when using `cmake`) when configuring,
this will install the program under `~/.opt/progname` automatically when running `make install`.


EXPLANATIONS
------------

Many programs rely on environment variable to find their dependencies. The `PATH` environment
variable is well known, but many forget to also setup `LD_LIBRARY_PATH` as well, which is
required if the programs in `PATH` use dynamic libraries that are not in the default search
path. This script is there to help correctly setting up all those variable.

Here is the description of each variable handled:

  - `PATH`: used by shell(s) and other programs to find binaries, usually under `/usr/bin`
  - `LD_LIBRARY_PATH`: used by the `ld` dynamic linker to find dynamic libraries, usually under `/usr/lib`
  - `LIBRARY_PATH`: used by compilers to find dynamic and static libraries at compile time, usually under `/usr/lib`
  - `CPATH`: used by C and C++ compilers to find header files at compile time, usually under `/usr/include`
  - `PKG_CONFIG_PATH`: used by `pkg-config` to find `.pc` library descriptor files, usually under `/usr/lib/pkgconfig`
  - `MANPATH`: used by `man` to find man pages, usually under `/usr/man` or `/usr/share/man`
  - `PYTHONPATH`: used by `python` to find python packages, usually under `/usr/lib/pythonX.Y/site-packages`

NOTE: `PYTHONPATH` is handled differently because its value depends on the python ultimately
called (the python version apearing in the PATH). This makes it difficult to handle cases where
both python2 and python3 have different set of packages. To handle the problem, `my` takes care
of always having its personal directory first in `PATH` which contains wrapper script for python.
Those wrapper script should catch any call to any version of `python` thanks to the many
symbolic links. Once the call is catched, it will use the actual version of the requested python
to correctly setup PYTHONPATH and only then perform the actual call.

NOTE: The reason why `my.sh` cannot be a binary and must be sourced is that it has to be a
shell function to be able to change the environment of the current running shell. The python
wrappers, on the other hands, could have been compiled binaries, as they only modify the
environment for subprocesses.
