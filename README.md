# Shell Links (shln)

shln is a simple set of shell scripts that allow symoblic linking from a folder in the PATH (usually /usr/local/shln) to shell scripts under a user folder (usually ~/shln).

Why?  Only a single PATH entry needs to be made, all the shell script links are in one place, and links can be easily added or removed.

# Install

To install, clone this repository to ~/shln/github.com/sageify/shln:

```bash
# create directory
mkdir -p ~/shln/github.com/sageify/shln
cd ~/shln/github.com/sageify/shln

# clone desired version into current directory
git clone --branch v0.0.2 --depth 1 https://github.com/sageify/shln.git .

# install the /usr/local/shln folder and add shln itself
./install-shln.sh
```

Update linux PATH variable to add the /usr/local/shln folder.  This varies depending on your platform.

For example, on debian:
```bash
# edit profile script and adjust PATH
# PATH=/usr/local/shln:$PATH
sudo nano /etc/profile
```

# Usage

```bash
# Assuming /usr/local/shln has been added to the PATH 
shln
```

# Hello World

To add manually add a hello world script for use under shln:

```bash
cd ~/shln

# create simple hello world
echo "echo hello, world" > hello.sh
chmod +x hello.sh


# show all current links
shln ls -al

# manually link "hello" to hello.sh
shln ln hello

# Run hello.sh
hello

# Cleanup
shln rm hello
rm hello.sh
```

# Package Example

Any git repository may be used as a package of shell scripts.  A collection of shell scripts that wrap docker are available at [dockcmd](https://github.com/dockcmd).

Assuming docker is installed, the following will install the aws cli:

```bash
# Install shell module support required by aws-sh
shln install github.com/sageify/shmod v0.0.1

# Install aws cli
shln install github.com/dockcmd/aws-sh v0.0.1

aws --version
```

# References

Shell documentation:

https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
