# sourced into shln.sh

set -e

# Install a shln module:
# shln install dockcmd/aws-sh@v0.0.1
# shln install github.com/dockcmd/aws-sh@v0.0.1

shpack_install() {
  shmod_repo_tag_dir $1

  ! git ls-remote -h $repo && exit 1

  # Add SHPACK_PATH to dir.  SHPACK_PATH is set in shln.sh from which this should be sourced
  dir=$SHPACK_PATH/$dir

  if [ -f "$dir" ] || [ -d "$dir" ]
  then
    echo fatal: repository or file already exists: $dir 1>&2
    exit 1
  fi

  shmod_clone $repo "$tag" $dir "--depth 1"

  # if more than one script, don't link
  [ $(ls $dir/*.sh | wc -l) -ne 1 ] && return

  script=$(ls $dir/*.sh)
  link_name=$SHLN_PATH/$(basename $script | rev | cut -c 4- | rev)

  ln -s "$script" "$link_name"

  # reset cache for where executable found in case link covers an existing executable
  hash -r

  ls -l "$link_name" | cut -c 10-
}

if ! [ $1 ]
then
  echo Usage: shln install REPOSITORY[@BRANCH_TAG]  1>&2
  exit 1
fi

# get repo, dir and tag
. shmod

if [ "$1" == "-" ]
then
  read args
  for arg in $args shln
  do
    shpack_install $arg
  done
  exit 0
fi

for pack in "$@"
do
  shpack_install $pack
done
