# Shell Links (shln)

shln is a git package manager for shell scripts that allow symoblic linking from a folder in the PATH (usually /usr/local/shln) to shell scripts under a user folder (usually ~/shln).

Why?  
- The shell script links are in one place.
- Links can be easily added or removed.
- New scripts can be installed from git repositories.

## Install

To install on Mac/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/sageify/shln/master/install.sh | sh
```

If needed, add ~/bin to path:

```bash
# edit profile script and adjust PATH
# PATH=$HOME/bin:$PATH
sudo nano /etc/profile

# OSX
sudo nano /etc/paths
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
import dockcmd/sh@v0.0.2 docker.sh

```

By default, the files are imported to ~/shmod directory.  To specific a folder, set the SHMOD_PATH environment variable.
