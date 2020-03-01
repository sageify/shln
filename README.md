# Shell Links (shln)

shln is a simple set of shell scripts that allow symoblic linking from a path folder (usually /usr/local/shln) to a shell script in the user folder (usually ~/shln).

Why?  This keeps the PATH simple, provides all the links in one place, and allows links into any subfolder of the user folder.

# Install

To install, a clone this repository to ~/shln/github.com/sageify/shln:

```bash
mkdir -p ~/shln/github.com/sageify/shln
cd ~/shln/github.com/sageify/shln
git clone --branch v0.0.2 --depth 1 https://github.com/sageify/shln.git .
```

The install script creates the /usr/local/shln, 

```bash
./install-shln.sh
```

Update linux PATH variable to add the /usr/local/shln folder.  This varies depending on your platform.

# Usage

```bash
shln
```

# References

Shell documentation:

https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
