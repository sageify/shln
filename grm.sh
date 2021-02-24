#!/bin/sh

grm_clone() {
  if ! [ $2 ]; then
    echo grm_clone: Requires two parameters: home repo 1>&2
    exit 1
  fi

  grm_repo_tag_dir $2

  dir=$1/$dir${tag:+@$tag}

  if [ -d "$dir" ]; then
    echo $dir
    return
  fi

  ! mkdir -p $dir &&
    return 1

  if ! git clone -q ${tag:+--branch $tag} $repo $dir; then
    ! [ "$(ls -A $dir)" ] && rm -r $dir
    return 1
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

  repo=${repo%.git}

  # redefine repo
  case $repo in
  .. | */.. | */../* | ../*)
    echo grm_repo_tag_dir: $repo: Can not use .. in repository name 1>&2
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
    echo grm_repo_tag_dir: $1: Invalid repository name 1>&2
    exit 1
    ;;
  esac
}

grm_diff() {
  if ! [ $2 ]; then
    echo grm_diff: Requires two parameters: HOME REPO 1>&2
    exit 1
  fi

  grm_repo_tag_dir $2  
  dir=$dir${tag:+@$tag}
  grm_diff_path_dir $1/$dir $dir 
}

grm_diff_path_dir() {
  if [ "$HOME" = "$1" ] || [ "/" = "$1" ]; then
    echo grm_diff: $1: Invalid directory 1>&2
    return 1
  fi

  if ! [ -d "$1/.git" ]; then
    echo grm_diff: $1: No .git directory 1>&2
    return 1
  fi

  cd $1

  # deleted, modified, other (unstaged)
  for file in $(git ls-files -dmo); do
    echo $2/$file
  done

  # staged changes
  for file in $(git diff --cached --name-only); do
    echo $2/$file
  done

  # committed but not pushed
  for file in $(git log --branches --not --remotes --name-only --format="$d"); do
    echo $2/$file
  done

  return 0
}

if [ -L "$0" ]; then
  GRM_SCRIPT_HOME=$(dirname $(readlink "$0"))
else
  GRM_SCRIPT_HOME=$(dirname "$0")
fi

GRM_HOME=${GRM_HOME-$(cd $GRM_SCRIPT_HOME/../../.. && pwd -P)}
GRM_DEFAULT_SCHEME=${GRM_DEFAULT_SCHEME-https}
GRM_DEFAULT_HOST=${GRM_DEFAULT_HOST-github.com}

if [ $1 ]; then
  GRM_SCRIPT=$GRM_SCRIPT_HOME/grm-$1.sh
  shift
  if ! [ -f "$GRM_SCRIPT" ]; then
    GRM_SCRIPT=$GRM_SCRIPT_HOME/grm-help.sh
  fi
else
  GRM_SCRIPT=$GRM_SCRIPT_HOME/grm-help.sh
fi

. $GRM_SCRIPT "$@"
