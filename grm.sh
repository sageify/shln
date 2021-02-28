#!/bin/sh

# return local directory for repo
grm_dir() {
  repo=${1%.git}
  
  if ! [ "$repo" ]; then
    echo "dir: repository may not be empty" 1>&2
    return 1
  fi 

  case $repo in
  .. | */.. | */../* | ../*)
    echo "dir: $repo: Can not use .. in repository name" 1>&2
    return 1
    ;;
  https://*) echo ${GRM_HOME:+$GRM_HOME/}$repo | cut -c 9- ;;
  ssh://*) echo ${GRM_HOME:+$GRM_HOME/}$repo | cut -c 7- ;;
  */*/*) echo ${GRM_HOME:+$GRM_HOME/}$repo ;;
  */*) echo ${GRM_HOME:+$GRM_HOME/}$GRM_DEFAULT_HOST/$repo ;;
  *) echo ${GRM_HOME:+$GRM_HOME/}$GRM_DEFAULT_HOST/$GRM_DEFAULT_ORG/$repo ;;
  esac

  return 0
}

grm_which() {
  dir=$(grm_dir "$1") && git -C "$dir" rev-parse && echo $dir
}

# set repo and tag
grm_set_repo_tag() {
  IFS='@' read repo tag <<EOF
$1
EOF

  repo=${repo%.git}

  if ! [ "$repo" ]; then
    echo "repo: repository may not be empty" 1>&2
    return 1
  fi

  case $repo in
  .. | */.. | */../* | ../*)
    echo "repo: $repo: Can not use .. in repository name" 1>&2
    return 1
    ;;
  https://*) repo=$repo.git ;;
  ssh://*) repo=$repo.git ;;
  */*/*) repo=$GRM_DEFAULT_SCHEME://$repo.git ;;
  */*) repo=$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$repo.git ;;
  *) repo=$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$GRM_DEFAULT_ORG/$repo.git ;;
  esac

  return 0
}

grm_diff() {
  # deleted, modified, other (unstaged)
  for file in $(git -C "$1" ls-files -dmo --exclude-standard); do
    echo $2$file
  done

  # staged changes
  for file in $(git -C "$1" diff --cached --name-only); do
    echo $2$file
  done

  # committed but not pushed
  for file in $(git -C "$1" log --branches --not --remotes --name-only --format="$d"); do
    echo $2$file
  done
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
