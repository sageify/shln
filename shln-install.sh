# sourced into shln.sh

set -ex

# Install a shln module:
#
# shln install dockcmd/aws-sh
# shln install github.com/dockcmd/aws-sh@v0.0.1
#
shpack_install() {
  dir=$(GRM_HOME=$GRM_HOME grm -clone $1)
  [ $? -ne 0 ] && exit 1
  
  script=$(ls $dir/*.sh)
  [ $? -ne 0 ] && exit 1

  # if more than one script, don't link
  [ $(echo $script | wc -w) -ne 1 ] && 
    exit 0

  link_name=$SHLN_HOME/$(basename $script | rev | cut -c 4- | rev)

  ln -s "$script" "$link_name"

  # reset cache for where executable found in case link covers an existing executable
  hash -r

  ls -l "$link_name"
}

if ! [ $1 ]; then
  echo Usage: shln install REPOSITORY[@BRANCH_TAG] 1>&2
  exit 1
fi

if [ "$1" = "-" ]; then
  while read -r line || [ $line ]; do
    for arg in $line; do
      shpack_install $arg
    done
  done
  exit 0
fi

for pack in "$@"; do
  shpack_install $pack
done
