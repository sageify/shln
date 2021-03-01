# Groom

Groom is a git repository manager simplifying the cloning and coding within git repositories.

## Comman Usage

```bash
# launch visual studio code for the supplied repository, cloning if neccessary
grm code sageify/shln

# find a file in all repositories
grm find README.md

# show diffs for all cloned repositories (both are equivalent)
grm diff
grm diff $(grm find)
grm diff -a

# show diffs for a single repository
grm diff sageify/shln

# show actual location of a repository
grm which sageify/shln

# show the groom environment
grm env

# execute the pwd command within the Groom home direcotry
grm exec pwd

# show groom help
grm

# pull latest for a repo
grm pull sageify/shln

```


## Advanced Usage

```bash
# change to the directory of a repository
cd $(grm which sageify/shln)

# rename a link
lnkn mv terraform tf

```