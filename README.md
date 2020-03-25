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

# Example

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
