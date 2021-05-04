# Envy

Envy manages enviornment variable contexts.  


## Basic Usage

In it's basic usage, it simply shows non-system environment variables:

```sh
nv
# CUSTOM=Hello World!
# OTHER=One
```

To see just the shell variables:

```sh
nv %
# HOST=
# PATH= ..
```

Shell variables are selected by a grep pattern.  The shell pattern may be replaed by
setting the ENVY_SHELL environment variable or extra patterns added using ENVY_SHELL_EXTRA:

```sh
nv pattern -s
# COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOME$|LANG$ ...
```

Add new exported variables to environment

```sh
nv SAY='Hello World!'
nv
```

Save variables

```sh
nv save
# nv/default..
```


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

By default, Envy attempts to load the nv/default environment file.  Multiple files may
exist.

```sh
# create a new working environment named goodbye
nv new goodbye

# creates a clean slate
nv

# add some environment variables
nv SAY='Goodbye World!'
nv SAY_ES='Adiós Mundo!'
nv save
# nv/goodbye..

# see full environemnt
nv
# SAY=Goodbye World!

# show saved environment file
nv cat
#
#

# replace with default
nv open default
nv

```

## Domains

Domains are mutually exclusive environments.  Only one environment file may be opened in a domain at one time.

For example, only one git configuration should be available at one time.

```sh
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
nv .
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

By default, envy.sh looks in .config/envy for configuration files.  The .config/envy/.nvrc file, if exists, will load enviornment variables.

To edit

```sh
nv nano @@/.nvrc
``

Or create

```sh
cat > $(nv home)/.nvrc <<_
VISUAL=code
_
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

