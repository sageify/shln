# Git Repository Manager

`grm` behaves lik `shln`, everything is just a pass through to the default directory the contains the git repositories.

## --find

List all the packages.

```bash
# list all packages - github.com/sageify/shln
grm -find
grm find -x . -mindepth 3 -maxdepth 3 -type d "$@" | cut -c 3-

grm -find helloworld.sh
grm find -x . -path "*helloworld.sh" | cut -c 3-

# list all packages with full directory name
grm -find -d
find -x $GRM_HOME -mindepth 3 -maxdepth 3 -type d "$@"

grm -find -d helloworld.sh
find -x $GRM_HOME -path "*helloworld.sh" 

grm -clone sageify/shln

```