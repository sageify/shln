# Shell Links (shln)

shln is a simple set of shell scripts that allow symoblic linking from a folder in the PATH (usually /usr/local/shln) to shell scripts under a user folder (usually ~/shln).

Why?  Only a single PATH entry needs to be made, all the shell script links are in one place, and links can be easily added or removed.

## Install

To install, clone this repository to ~/shln/github.com/sageify/shln:

```bash
# create directory and change to that directory
mkdir -p ~/shln/github.com/sageify/shln && cd $_

# clone desired version into current directory
git clone --branch v0.0.2 --depth 1 https://github.com/sageify/shln.git .

# to install the $HOME/bin (ubnutu will pick up automatically for path)
./install-home-bin.sh

# to install to usr/local/shln
./install-usr-local.sh
```

If install the usr-local or not on ubuntu, update linux PATH variable to add the /usr/local/shln folder.

```bash
# edit profile script and adjust PATH
# PATH=/usr/local/shln:$PATH
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

## Module Support

Any git repository may be used as a package of shell scripts.  A collection of shell scripts that wrap docker are available at [dockcmd](https://github.com/dockcmd).

Assuming docker is installed, the following will install the aws cli:

```bash
# Install shell module support required by aws-sh
shln install github.com/sageify/shmod v0.0.3

# Install aws cli
shln install github.com/dockcmd/aws-sh v0.0.1

aws --version
```

# References

Shell documentation:

https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
