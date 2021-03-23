# Envy

Envy manages enviornment variable contexts.  A context consists of a context name and a grep pattern.  A context is created as follows:

```sh
nv close -a
nv new hello '^SAY='
nv set SAY='Hello World!'
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


## References
http://www.etalabs.net/sh_tricks.html