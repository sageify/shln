# Groom

Groom is a git repository manager simplifying the cloning and coding within git repositories.

Groom makes it easy to:

- Clone git repositories into a standard local directory
- Safely remove repositories
- Find diffs for all repositories
- Easily start an editor for a repository

## Comman Usage

```sh
# launch visual studio code for the supplied repository, cloning if neccessary
grm edit sageify/shln
grm e sageify/shln

# find a file in all repositories
grm find "*README.md"

# show diffs for all cloned repositories (all are equivalent)
grm diff -a
grm diff $(grm)
grm d -a
grm da

# show diffs for a single repository
grm diff sageify/shln

# show actual location of a repository
grm which sageify/shln
grm w sageify/shln

# show the groom environment
grm env

# execute the pwd command within the Groom home direcotry
grm exec pwd

# show groom help
grm help

# pull latest for a repo
grm pull sageify/shln

# menu based approach
grm menu edit
# 1 2

```


## Advanced Usage

```sh
# change to the directory of a repository
cd $(grm which sageify/shln)

# rename a link
lnkn mv terraform tf

```


## Todo
