# Envy

Envy manages enviornment variable contexts.  A context consists of a context name and a grep pattern.  A context is created as follows:

```sh
# unload any previous context
nv unload

# declare pattern
nv pattern "^GRM_|^HELLO"
export GRM_DEFAULT_ORG=sageify
export HELLO='Hello World!'

# show variables under management
nv

# save default context
nv save

# context set to default
nv context

# unload context
nv unload

# no context
nv context
```

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

# nvy export
nve load c

typeset -f

# save current by nvy_PATTERN
nve save <file>
```

## Notes
