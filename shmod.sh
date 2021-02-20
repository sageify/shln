#!/bin/sh
set -e

# <repo>@<tag/branch> <file1> <file2>
# import dockcmd/sh@v0.0.2 docker.sh
#
import() {
  if ! [ $2 ]; then
    echo File missing: $1 1>&2
    echo Usage: import repo@tag file1 file2 ...
    exit 1
  fi

  ! _source=$(shmod_source $1) &&
    exit 1

  for _script in $2; do
    . $_source/$_script
  done

  # since shmod.sh is sourced, and import() can't be called in a subprocess,
  # need to get rid of local variables.
  unset _source
  unset _script
}

# <repo>
shmod_source() {
  grm_repo_tag_dir $1

  if ! [ $tag ]; then
    echo Repository tag missing: $1 1>&2
    echo Usage: repo@tag
    exit 1
  fi

  if ! grm_clone $1 $SHMOD_HOME; then
    exit 1
  fi

  echo "$dir"
}

grm_clone() {
  if ! [ $1 ]; then
    echo grm: Missing repo 1>&2
    exit 1
  fi

  if ! [ $2 ]; then
    echo grm: Missing home directory 1>&2
    exit 1
  fi

  grm_repo_tag_dir ${1%.git}

  dir=$2/$dir${tag:+@$tag}

  if [ -f "$dir" ] || [ -d "$dir" ]; then
    echo $dir
    exit 0
  fi

  ! mkdir -p $dir &&
    exit 1

  if ! git clone -q ${tag:+--branch $tag} $repo $dir; then
    ! [ "$(ls -A $dir)" ] && rm -r $dir
    exit 1
  fi

  echo $dir
}

# sets the repo, tag, amd dir
# sageify/shmod@v0.0.1
# repo=https://github.com/sageify/shmod.git
# tag=v0.0.1
# dir=github.com/sageify/shmod
grm_repo_tag_dir() {
  IFS='@' read repo tag <<EOF
$1
EOF

  # redefine repo
  case $repo in
  .. | */.. | */../* | ../*)
    echo shmod: $1: Can not use .. in repository name 1>&2
    exit 1
    ;;
  *.git)
    echo shmod: $1: Repository name should not end with .git >&2
    exit 1
    ;;
  https://*)
    dir=$(echo $repo | cut -c 9-)
    repo=$repo.git
    ;;
  ssh://*)
    dir=$(echo $repo | cut -c 7-)
    repo=$repo.git
    ;;
  */*/*)
    dir=$repo
    repo=$GRM_DEFAULT_SCHEME//$repo.git
    ;;
  */*)
    dir=$GRM_DEFAULT_HOST/$repo
    repo=$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$repo.git
    ;;
  *)
    echo Invalid repository name: $1 1>&2
    exit 1
    ;;
  esac
}

# set shmod environment variables
SHMOD_HOME=${SHMOD_HOME-$HOME/.shmod}
GRM_DEFAULT_SCHEME=${GRM_DEFAULT_SCHEME-https}
GRM_DEFAULT_HOST=${GRM_DEFAULT_HOST-github.com}
