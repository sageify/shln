# Shell Links (shln)

shln manages git packages, shell modules, and links that allow symoblic linking from a folder in the PATH (usually /usr/local/shln) to shell scripts under a user folder (usually ~/shln).

Why?  
- Manage links to shell scripts and programs in one place.
- Links can be easily added or removed.
- Manage git repositories containing scripts and programs.

## Install

To install on Mac/Linux/WSL2:

```bash
curl -fsSL https://raw.githubusercontent.com/sageify/shln/master/install.sh | sh
```

## Usage

```bash
# Assuming PATH has been updated 
shln
```

## Hello World

To add a hello world script for use under shln:

```bash
cd ~/shln

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

## Shell Script Package Support

Any git repository may be used as a package of shell scripts.  A collection of shell scripts that wrap docker are available at [dockcmd](https://github.com/dockcmd).

Assuming docker is installed, the following will install the aws cli:

```bash
# Install aws cli
shln tag dockcmd/aws-sh
shln install dockcmd/aws-sh@v0.0.3

aws --version
```

## Shell Script Modules

### Usage

```bash
#!/bin/bash

. shmod
import dockcmd/sh@v0.0.3 docker.sh

```

By default, the files are imported to ~/.shmod directory.  To specific a folder, set the SHMOD_HOME environment variable.
