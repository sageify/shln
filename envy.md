# Envy

Envy manages enviornment variable contexts.  A context consists of a context name and a grep pattern.  A context is created as follows:

```sh
# unload any previous context
nv new '^SAY'
get SAY='Hello World!'
nv put hello

# show variables under management
nv

# show saved file
nv cat

# context set to default
nv context

# unset pattern '^SAY'
nv unset

# nothing to see
nv

# get current context again
nv get
```

## Directories

Directories provide a way to store mutual exclusive environment contexts.  In other words, only one context may be loaded from a directory at the same time.

For example, only one git configuration should be available at one time.

``sh
nv new '^SAY='
get SAY='Hello World!'
nv put hello

nv new '^GIT_'
get GIT_COMMITTER_NAME='John Doe'
get GIT_COMMITTER_EMAIL='john@example.com'
get GIT_AUTHOR_NAME='John Doe'
get GIT_AUTHOR_EMAIL='john@example.com'
nv put git/john

nv new '^GIT_'
get GIT_COMMITTER_NAME='Jane Doe'
get GIT_COMMITTER_EMAIL='jane@example.com'
get GIT_AUTHOR_NAME='Jane Doe'
get GIT_AUTHOR_EMAIL='jane@example.com'
nv put git/jane

nv new '^SAY='
get SAY='Goodbye!'
nv put goodbye

nv get hello
nv


``



## Install

```sh
. ./nv.sh
typeset -f
```





## Comman Usage

```sh
# show current pattern
nv context

# load current context
nv load 

# initialize new


# load default
nve load

# nvy get
nve load c

typeset -f

# save current by nvy_PATTERN
nve save <file>
```

## Notes
