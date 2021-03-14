#!/bin/sh
g() {
  case "$1" in
  '' | --ls)
    g -l
    ;;

  menu | m | -m)
    shift && case "$1" in
    --) shift && g -me "$@" ;;
    -*) __="${1#-}" && shift && g "-m$__" "$@" ;;
    *) g -me "$@" ;;
    esac
    ;;
  -me | -em) grm_menu Edit -e- ;;
  -md | -dm) grm_menu Diff -d- ;;
  -mp | -pm) grm_menu Pull -p- ;;
  -mh | -hm) echo "usage: menu -edph" ;;

  ls | -l | -l-)
    if [ "$2" ]; then
      cd -- "$(grm -w "$2")" && find . -maxdepth 1 -type f | cut -c 3-
    else
      grm_cd && find . -mindepth 3 -maxdepth 3 -type d | cut -c 3- | sort
    fi
    ;;

  clone | c | -c | -c-)
    shift
    for repo in "$@"; do
      [ "$repo" ] && grm_clone "$repo"
    done
    ;;

  diff | d | -d)
    shift && case "$1" in
    --) shift && g -d- "$@" ;;
    -*) __="${1#-}" && shift && g "-d$__" "$@" ;;
    *) g -d- "$@" ;;
    esac
    ;;
  -d-)
    shift
    for repo in "$@"; do
      [ "$repo" ] &&
        path="$(g -w- "$repo")" &&
        dir="$(GRM_HOME='' grm_dir "$repo")" &&
        grm_diff "$path" "$dir/"
    done
    ;;
  -da | -ad) shift && g -l "$@" | while read -r repo; do g -d- "$repo"; done ;;
  -dh | -hd)
    echo "usage: $(basename -- "$0") --diff [-ah] org/repo[@tag] ..."
    echo "       $(basename -- "$0") --diff sageify/sh dockcmd/misc-sh"
    echo "       $(basename -- "$0") --diff sageify/sh@v0.0.1"
    ;;

  edit | e | -e | -e-)
    shift
    ! command -v -- "$GRM_EDITOR" >/dev/null &&
      echo "edit: Editor '$GRM_EDITOR' not found" 1>&2 &&
      return 1

    for repo in "$@"; do
      [ "$repo" ] && dir="$(g -c- "$repo")" && $GRM_EDITOR "$dir"
    done
    ;;

  env)
    echo "GRM_DEFAULT_HOST=$GRM_DEFAULT_HOST"
    echo "GRM_DEFAULT_ORG=$GRM_DEFAULT_ORG"
    echo "GRM_DEFAULT_SCHEME=$GRM_DEFAULT_SCHEME"
    echo "GRM_HOME=$GRM_HOME"
    echo "GRM_SCRIPT_HOME=$GRM_SCRIPT_HOME"
    ;;

  find | f | -f | -f-) grm_cd && find . -path "./${2-*}" | cut -c 3- ;;

  exec) shift && grm_cd && exec "$@" ;;

  pull | p | -p)
    shift && case "$1" in
    --) shift && g -p- "$@" ;;
    -*) __="${1#-}" && shift && g "-p$__" "$@" ;;
    *) g -p- "$@" ;;
    esac
    ;;
  -p-)
    shift
    for repo in "$@"; do
      [ "$repo" ] && dir="$(grm_dir "$repo")" && git -C "$dir" pull
    done
    ;;
  -pa | -ap) shift && g -l "$@" | while read -r repo; do g -p- "$repo"; done ;;
  -ph | -hp)
    echo "usage: $(basename -- "$0") --pull [-ah] org/repo[@tag] ..."
    echo "       $(basename -- "$0") --pull sageify/sh dockcmd/misc-sh"
    echo "       $(basename -- "$0") --pull sageify/sh@v0.0.1"
    ;;

  rm | -r-)
    shift
    for repo in "$@"; do
      ! dir=$(g -w- "$repo") || ! diff=$(grm_diff "$dir") &&
        return 1

      if [ "$diff" ]; then
        echo "grm: $dir: Deleted, modified, unstaged, staged, or unpushed files exist:" 1>&2
        echo "$diff" 1>&2
        return 1
      fi

      printf %s "Remove $dir (y/n): " &&
        read -r yn &&
        [ "$yn" = "y" ] &&
        rm -rf -- "$dir"
    done
    ;;

  tags)
    shift
    grm_set_repo_tag "$1"

    git ls-remote --tags "$repo" | while read -r _ t; do
      basename -- "$t"
    done
    ;;

  which | w | -w | -w-)
    ! [ "$2" ] && printf %s\\n "$GRM_HOME" && return 0

    shift
    for repo in "$@"; do
      dir="$(grm_dir "$repo")" && git -C "$dir" rev-parse && printf %s\\n "$dir"
    done
    ;;

  help | -h | --help | -h-)
    cat <<EOF
Usage:	$(basename -- "$0") COMMAND

Git repository manager.

Git Commands
-c, clone   clone a repository
-d, diff    show any differences in local repository vs remote
-p, pull    pull from remote repository
-r, rm      safely remove repository if no differences with remote
-t, tags    show remote tags

General Commands
-e, edit    launch visual studio code for repository, cloning if necessary
    env     show the groom envinroment variables
    exec    execute any linux command in groom home ($GRM_HOME)
-f, find    find files in local repositories
    ls      list all repos
-m, menu    list menu of repos to edit
-w, which   locate a repository in groom home ($GRM_HOME)
-h, help    show this page
EOF
    ;;
  -*)
    echo "grm: $1: Option not found" 1>&2
    g -h- 1>&2 || return 1
    ;;
  *)
    echo "grm: $1: Option not found" 1>&2
    g -h- 1>&2 || return 1
    ;;
  esac
}

# return local directory for repo
grm_dir() {
  repo="${1%.git}"

  if ! [ "$repo" ]; then
    echo "dir: repository may not be empty" 1>&2
    return 1
  fi

  case $repo in
  .. | */.. | */../* | ../*) echo "dir: $repo: Can not use .. in repository name" 1>&2 && return 1 ;;
  https://*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$repo" | cut -c 9- ;;
  ssh://*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$repo" | cut -c 7- ;;
  */*/*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$repo" ;;
  */*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$GRM_DEFAULT_HOST/$repo" ;;
  *) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$GRM_DEFAULT_HOST/$GRM_DEFAULT_ORG/$repo" ;;
  esac

  return 0
}

grm_menu() {
  if [ "$2" ] && g -l- | cat -n &&
    printf %s "$1 repo number(s): " && read -r _menu_lines; then
    for _menu_line in $_menu_lines; do
      [ "$_menu_line" -eq "$_menu_line" ] 2>/dev/null &&
        _menu_repo=$(g -l- | sed "$_menu_line"'!d') &&
        [ "$_menu_repo" ] &&
        printf %s\\n "$_menu_repo" &&
        g "$2" "$_menu_repo"
    done
    return 0
  fi
}

# set repo and tag
grm_set_repo_tag() {
  IFS='@' read -r repo tag <<EOF
$1
EOF
  repo="${repo%.git}"

  if ! [ "$repo" ]; then
    echo "repo: repository may not be empty" 1>&2
    return 1
  fi

  case "$repo" in
  .. | */.. | */../* | ../*)
    echo "repo: $repo: Can not use .. in repository name" 1>&2
    return 1
    ;;
  https://*) repo="$repo.git" ;;
  ssh://*) repo="$repo.git" ;;
  */*/*) repo="$GRM_DEFAULT_SCHEME://$repo.git" ;;
  */*) repo="$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$repo.git" ;;
  *) repo="$GRM_DEFAULT_SCHEME://$GRM_DEFAULT_HOST/$GRM_DEFAULT_ORG/$repo.git" ;;
  esac

  return 0
}

grm_diff() {
  # deleted, modified, other (unstaged)
  git -C "$1" ls-files -dmo --exclude-standard | while read -r file; do
    printf %s\\n "$2$file"
  done

  # staged changes
  git -C "$1" diff --cached --name-only | while read -r file; do
    printf %s\\n "$2$file"
  done

  # committed but not pushed
  git -C "$1" log --branches --not --remotes --name-only --format="%d" | while read -r file; do
    printf %s\\n "$2$file"
  done
}

grm_cd() {
  if ! cd "$GRM_HOME" 2>/dev/null; then
    echo "$GRM_HOME directory does not exist" 1>&2
    exit 1
  fi
}

grm_clone() {
  # not doing which. directoy does not need to exist
  ! dir="$(grm_dir "$1")" && return 1

  if [ -d "$dir" ]; then
    # not currently validating as a real directory, allows shmod to run faster
    printf %s\\n "$dir"
    return 0
  fi

  grm_set_repo_tag "$1"
  # shellcheck disable=SC2154,SC2086
  if ! git -c advice.detachedHead=false clone $clone_opts -q ${tag:+--branch "$tag"} "$repo" "$dir"; then
    echo "clone: $clone_opts -q ${tag:+--branch "$tag"} $repo $dir" 1>&2
    return 1
  fi

  printf %s\\n "$dir"
}

if [ -L "$0" ]; then
  GRM_SCRIPT_HOME="$(dirname -- "$(readlink -- "$0")")"
else
  GRM_SCRIPT_HOME="$(dirname -- "$0")"
fi

GRM_HOME="${GRM_HOME-$(cd "$GRM_SCRIPT_HOME/../../.." && pwd -P)}"
GRM_DEFAULT_SCHEME="${GRM_DEFAULT_SCHEME-https}"
GRM_DEFAULT_HOST="${GRM_DEFAULT_HOST-github.com}"
GRM_EDITOR='code'

g "$@"
