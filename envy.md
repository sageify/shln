# Envy

Envy manages enviornment variable contexts.  


## Basic Usage

In it's basic usage, it simply shows non-system environment variables:

```sh
nv
# CUSTOM=Hello World!
```

The non-system environment variables excluded are:

```sh
nv exclude
# COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOME$|LANG$ ...
```

Prevents exporting of system variables

```sh
nv PATH=
# nv: export: 'PATH=': bad variable name
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


## Multiple Environment Management

A context consists of a context name and a grep pattern.  A context is created as follows:

```sh

# get fresh environment
nv ca
nv ua

nv new hello 'SAY$'
nv export SAY='Hello World!'
nv
nv save

# see full environemnt
env

# managed environment
nv .

# show saved file
nv cat

# close
nv close

# nothing to see
nv

# open context 
nv open
nv
```

## Domains

Domains provide a way to store mutually exclusive environment contexts.  In other words, only one context may be loaded in the domain at the one same time.

Domains are established by creating a context directory.

For example, only one git configuration should be available at one time.

``sh
nv new nv/hello SAY=
nv set SAY='Hello World!'
nv save

nv new git/john GIT_
nv set GIT_COMMITTER_NAME='John Doe'
nv set GIT_COMMITTER_EMAIL='john@example.com'
nv set GIT_AUTHOR_NAME='John Doe'
nv set GIT_AUTHOR_EMAIL='john@example.com'
nv save

nv new jane GIT_
nv set GIT_COMMITTER_NAME='Jane Doe'
nv set GIT_COMMITTER_EMAIL='jane@example.com'
nv set GIT_AUTHOR_NAME='Jane Doe'
nv set GIT_AUTHOR_EMAIL='jane@example.com'
nv save

nv cd nv
nv get SAY

nv new goodbye SAY=
nv set SAY='Goodbye!'
nv save
nv

nv open hello
nv

``


## Install

```sh
. ./nv.sh
typeset -f
```


## Todo

### 
- Ability to show all environment variables not being managed by an nv environment.  For example, if git environment only one loaded, show any other unmanaged. 

### Menu
- menu for envionrment value changing (menu set) - use nv edit

### Multi-Line

Multi-line support is provided in both .nvrc and environment files as follows:

```sh
VAR<<eof
Two line assignment
to variable
eof
```

## Developer Notes

Follow behavior of native printenv, env, export, and unset commands.
Follow behavior of busybox for return codes and error output.

### Export

The export -p command prints export statements in a platform specific format.  Same is true for nv.
The export -n removes export flag.

## References
http://www.etalabs.net/sh_tricks.html
https://man7.org/linux/man-pages/man7/glob.7.html