# Linkin (lnkn)

Linkin is a link manager primarily used with Groom to install git repositories and link to scripts within those repositories.

Why?  
- Manage links to shell scripts and programs in one place.
- Links can be easily added or removed.
- Install git repositories containing scripts and programs.

## Install

To install on Mac/Linux/WSL2:

```sh
curl -fsSL https://raw.githubusercontent.com/sageify/shln/master/install.sh | sh
```

## Usage

```sh
# Assuming PATH has been updated 
lnkn
```

## Cheat Sheet

```sh

# install dockcmd/misc-sh and link to alpine.sh
lnkn install dockcmd/misc-sh
lnkn grm alpine.sh
alpine
.s
```

## Hello World

To add a hello world script for use under lnkn:

```sh
cd $LNKN_HOME

# create simple hello world
echo "echo hello, world" > hello.sh
chmod +x hello.sh

# show all current links
shln ls -al

# link "hello" to hello.sh
shln ln hello

# Run hello.sh
hello

# Cleanup
shln rm hello
rm hello.sh
```

## Shell Module Support

Any git repository may be used as a package of shell scripts.  A collection of shell scripts that wrap docker are available at [dockcmd](https://github.com/dockcmd).

Assuming docker is installed, the following will install the aws cli:

```sh
# Install aws cli
grm tags dockcmd/aws-sh
lnkn install dockcmd/aws-sh@v0.0.3

aws --version
```

## Shell Script Modules

### Usage

```sh
#!/bin/sh

. shmod
import dockcmd/sh@v0.0.4 docker.sh

```

By default, the files are imported to ~/.shmod directory.  To specific a folder, set the SHMOD_HOME environment variable.


## Todo
- pull test/shert.sh into own github
- modify test scripts and use shmod to pull in the unit testing
- pull expansion into own.
- clone_opts in shmod.sh is hacky
- shomd -> shmd

## References
http://www.etalabs.net/sh_tricks.html
