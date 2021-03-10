# Envy

Envy manages enviornment variable contexts.  A context consists of a context name and a grep pattern.  A context is created as follows:

```sh
# unload any previous context
nv new '^SAY='
nv set SAY='Hello World!'
nv
nv save

# in full environemnt
env

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
nv new '^SAY='
export SAY='Hello World!'
nv save hello

nv new '^GIT_'
export GIT_COMMITTER_NAME='John Doe'
export GIT_COMMITTER_EMAIL='john@example.com'
export GIT_AUTHOR_NAME='John Doe'
export GIT_AUTHOR_EMAIL='john@example.com'
nv save git/john

nv new '^GIT_'
export GIT_COMMITTER_NAME='Jane Doe'
export GIT_COMMITTER_EMAIL='jane@example.com'
export GIT_AUTHOR_NAME='Jane Doe'
export GIT_AUTHOR_EMAIL='jane@example.com'
nv save jane

nv new '^SAY='
export SAY='Goodbye!'
nv save goodbye
nv

nv open hello
nv

``



## Install

```sh
. ./nv.sh
typeset -f
```



## Resolve

nv resolve [-c] [-d] name

Resolve a name.  Returns -1 if invalid name. -c resolve to a context, -d resolve to a domain.

## Notes

Revert to behavior in busy box.


## env, export, set and unset

### set



## References
http://www.etalabs.net/sh_tricks.html