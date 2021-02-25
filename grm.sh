#!/bin/sh

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
    echo repo: $repo: Can not use .. in repository name 1>&2
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
    repo=$GRM_DEFAULT_SCHEME://$repo.git
    ;;
  */*)
    dir=$GRM_DEFAULT_HOST/$repo
    repo=$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$repo.git
    ;;
  *)
    echo repo: $repo: Invalid repository name 1>&2
    exit 1
    ;;
  esac
}

grm_diff() {
  if ! [ $2 ]; then
    echo diff: Requires two parameters: HOME REPO 1>&2
    exit 1
  fi

  grm_repo_tag_dir $2
  dir=$dir${tag:+@$tag}
  grm_diff_path_dir $1/$dir $dir
}

grm_diff_path_dir() {
  if [ "$HOME" = "$1" ] || [ "/" = "$1" ]; then
    echo diff: $1: Invalid directory 1>&2
    return 1
  fi

  if ! [ -d "$1" ]; then
    echo diff: $1: directory not found 1>&2
    return 1
  fi

  if ! [ -d "$1/.git" ]; then
    echo diff: $1: directory not a git repository 1>&2
    return 1
  fi

  cd $1

  dir=${2:+$2/}

  # deleted, modified, other (unstaged)
  for file in $(git ls-files -dmo --exclude-standard); do
    echo $dir$file
  done

  # staged changes
  for file in $(git diff --cached --name-only); do
    echo $dir$file
  done

  # committed but not pushed
  for file in $(git log --branches --not --remotes --name-only --format="$d"); do
    echo $dir$file
  done

  return 0
}

grm_cd() {
  if ! cd $GRM_HOME 2>/dev/null; then
    echo $GRM_HOME directory does not exist 1>&2
    exit 1
  fi
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
