# Envy

Envy manages enviornment variable contexts.  


## Basic Usage

In it's basic usage, it simply shows non-system environment variables:

```sh
nv
# CUSTOM=Hello World!
# OTHER=One

nv /CUSTOM
# CUSTOM=Hello World!

nv /OTH
# OTHER=Hello World!
```

To see just the shell variables:

```sh
nv %
# PATH= ..
```

Shell variables are selected by a grep pattern:
```sh
nv pattern -s
# COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOME$|LANG$ ...
```

Add new variables

```sh
nv SAY='Hello World!'
nv
```

Save variables

```sh
nv save
# nv/default
```

If terminal is closed, variables will be available in next terminal

## Environment Grep Patterns

Envy allows grepping of environment variables by name:

```sh
nv /S
# SAY='Hello World!'
```

To grep a shell variable

```sh
nv %P
# PATH=...
```

## Multiple Environment

An environment has a name a grep pattern.

```sh
# create a new working environment named hello for the pattern SAY$
nv work hello SAY$  
nv SAY='Hi There!'
nv
nv save

# see full environemnt
nv

# managed environment
nv env

# show saved file
nv cat

# close
nv close

# nothing to see
nv open hello
nv

nv open default
nv


```

## Domains

Domains provide a way to store mutually exclusive environment contexts.  Only one context may be loaded in the domain at the one same time.

Domains are established by creating a context directory.

For example, only one git configuration should be available at one time.

```sh
nv new nv/hello SAY
nv SAY='Hello World!'
nv save

nv new git/john GIT_
nv GIT_COMMITTER_NAME='John Doe'
nv GIT_COMMITTER_EMAIL='john@example.com'
nv GIT_AUTHOR_NAME='John Doe'
nv GIT_AUTHOR_EMAIL='john@example.com'
nv save

# show both nv and git domains
nv

# show just current domain
nv .

# create new environment for jane in git domain (current working domain)
nv new jane GIT_
nv GIT_COMMITTER_NAME='Jane Doe'
nv GIT_COMMITTER_EMAIL='jane@example.com'
nv GIT_AUTHOR_NAME='Jane Doe'
nv GIT_AUTHOR_EMAIL='jane@example.com'
nv save

nv cd nv
nv SAY

nv new goodbye SAY
nv SAY='Goodbye!'
nv save
nv

# to replace the GIT domain with john:

nv open git/john
nv
```

## Grep

```sh
# grep shell
%P
%PATH
%PATH$

# grep nv
.GIT

# grep working environment
?GIT

# grep open domain
git/?GIT

# grep in a file
git/john?GIT
```

## Install

Envy is a shell function that should be sourced into the current shell.  To install, adjust .bash_profile, .zshenv, etc.

```sh
. ./envy.sh
```

By default, envy.sh looks in .config/envy for configuration files.  The .config/envy/env/.nvrc file, if exists, will load enviornment variables.

To edit

```sh
nv nano @@/.nvrc
``

Or create

```sh
cat > $(nv home)/.nvrc <<EOF
VISUAL=code
EOF
```

## Environment Files

### Multi-Line

Multi-line support is provided in both .nvrc and environment files as follows:

```sh
VAR<<eof
Two line assignment
to variable
eof
```


## Todo

### 
- Ability to show all environment variables not being managed by an nv environment.  For example, if git environment only one loaded, show any other unmanaged. 

### Menu
- menu for envionrment value changing (menu set) - use nv edit

### edit
- nv edit should behave like nv nano.  

## Developer Notes

Follow behavior of native printenv, env, export, and unset commands.
Follow behavior of busybox for return codes and error output.


## Advanced

```sh
# unset all nv variables
unset -v $(nv grep)
```


## References
http://www.etalabs.net/sh_tricks.html
https://man7.org/linux/man-pages/man7/glob.7.html

