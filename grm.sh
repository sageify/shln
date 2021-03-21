#!/bin/sh --posix
g() {
  case $1 in
  '') grm_find_pretty ;;

  clone | c | diff | d | edit | e | init | i | pull | p | resolve | rm | which | w)
    # normal style command
    cmd=$1
    shift && case $1 in
    -*) __="$1" && shift && g "$cmd$__" "$@" ;;
    *) g "$cmd--" "$@" ;;
    esac
    ;;

  clone-- | c--)
    shift && for name in $(grm_resolve "$@"); do
      grm_clone "$name"
    done
    ;;

  diff-- | d--)
    shift && for name in $(grm_resolve "$@"); do
      grm_diff "$(grm_resolve_dir "$name")" "$name/"
    done
    ;;
  diff-a | d-a | da)
    shift && grm_find | while read -r name; do
      grm_diff "$(grm_resolve_dir "$name")" "$name/"
    done
    ;;

  edit-- | e--)
    shift
    ! command -v -- "$GRM_EDITOR" >/dev/null &&
      echo "edit: Editor '$GRM_EDITOR' not found" 1>&2 &&
      return 1

    for e in $(grm_resolve "$@"); do
      ed=$(grm_resolve_dir "$e")
      [ -d "$ed" ] && $GRM_EDITOR "$ed" && continue
      grm_clone "$e" && $GRM_EDITOR "$ed" && continue
      grm_init "$e" && $GRM_EDITOR "$ed" && continue
    done
    ;;

  init-- | i--)
    shift
    for name in $(grm_resolve "$@"); do
      printf '%-35s\t' "$name"
      grm_init "$name"
    done
    ;;

  pull-- | p--)
    shift
    for name in $(grm_resolve "$@"); do
      printf '%-35s\t' "$name"
      git -C "$(grm_resolve_dir "$name")" pull
    done
    ;;
  pull-a | p-a | pa)
    shift && grm_find "$@" | while read -r name; do
      printf '%-35s\t' "$name"
      git -C "$(grm_resolve_dir "$name")" pull
    done
    ;;

  rm--)
    shift
    for dir in $(grm_resolve_name_dir "$@"); do
      ! diff=$(grm_diff "$dir") && return 1

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

  resolve--) shift && grm_resolve "$@" ;;
  resolve-d) shift && grm_resolve_name_dir "$@" ;;
  resolve-r) shift && grm_resolve_name_repo "$@" ;;

  which-- | w--) # which
    shift
    for wd in $(grm_resolve_name_dir "$@"); do
      git -C "$wd" rev-parse && printf %s\\n "$wd"
    done
    ;;

  #
  # Commands with no options, flags or subcommands ever
  #

  dirs) grm_dirs ;;

  env)
    echo "GRM_DEFAULT_HOST=$GRM_DEFAULT_HOST"
    echo "GRM_DEFAULT_ORG=$GRM_DEFAULT_ORG"
    echo "GRM_DEFAULT_SCHEME=$GRM_DEFAULT_SCHEME"
    echo "GRM_HOME=$GRM_HOME"
    ;;

  home) printf %s\\n "$GRM_HOME" ;;

  exec) shift && grm_cd && exec "$@" ;;

  find | f )
    grm_cd && find . -type f -path "./${2-*}" | cut -c 3-
    ;;

  ls)
    if [ "$2" ]; then
      __="$(grm_resolve_name_dir "$2")" && cd -- "$__" && find . -maxdepth 1 -type f | cut -c 3-
    else
      grm_find
    fi
    ;;

  menu | m)
    shift && case $1 in
    '') g m-h 1>&2 && return 1 ;;
    *) __="$1" && shift && g "menu-$__" "$@" ;;
    esac
    ;;
  menu-diff | md | dm | diff-m | d-m) grm_menu Diff diff-- ;;
  menu-edit | me | em | edit-m | e-m) grm_menu Edit edit-- ;;
  menu-pull | mp | pm | pull-m | p-m) grm_menu Pull pull- ;;
  menu-rm | mrm | rmm | rm-m) grm_menu Remove rm-- ;;

  tags)
    shift
    repo=$(grm_resolve_name_repo "$1") && git ls-remote --tags "$repo" | while read -r _ t; do
      basename -- "$t"
    done
    ;;

  version | --version) echo "$(basename -- "$0") version 0.5.0" ;;

  help | -h | --help)
    shift && case $1 in
    '') g h-- ;;
    *) g "help-$1" "$@" ;;
    esac
    ;;

  h--)
    cat <<EOF
Usage:	$(basename -- "$0") COMMAND

Git repository manager.

Git Commands
c, clone   Clone a repository
d, diff    Show any differences in local repository vs remote
i, init    Initialize a git repository
p, pull    Pull from remote repository
r, rm      Safely remove repository if no differences with remote
t, tags    Show remote tags

General Commands
e, edit     Launch editor for repository, cloning if necessary
   env      Show the groom envinroment variables
   exec     Execute any linux command in groom home ($GRM_HOME)
f, find     Find files in local repositories
   home     Show repository home directory ($GRM_HOME)
   ls       List all repos
m, menu     List menu of repos
   version  Print the version information
w, which    Print the repository location
   help     Show this page
EOF
    ;;
  help-diff | help-d | diff-h | dh)
    echo "usage: $(basename -- "$0") --diff [-ah] org/repo[@tag] ..."
    echo "       $(basename -- "$0") --diff sageify/sh dockcmd/misc-sh"
    echo "       $(basename -- "$0") --diff sageify/sh@v0.0.1"
    ;;
  help-menu | help-m | menu-h | mh) echo "usage: grm menu diff | edit | pull | rm" ;;
  help-pull | help-p | pull-h | ph)
    echo "usage: $(basename -- "$0") --pull [-ah] org/repo[@tag] ..."
    echo "       $(basename -- "$0") --pull sageify/sh dockcmd/misc-sh"
    echo "       $(basename -- "$0") --pull sageify/sh@v0.0.1"
    ;;

  -*)
    echo "grm: $1: Option not found" 1>&2
    g help 1>&2 || return 1
    ;;
  *)
    echo "grm: $1: Command not found" 1>&2
    g help 1>&2 || return 1
    ;;
  esac
}

# must be called with resolved name
grm_clone() {
  ! dir="$(grm_resolve_dir "$1")" && return 1

  if [ -d "$dir" ]; then
    # not currently validating as a real git directory, allows shmod to run faster, development
    printf %s\\n "$dir"
    return 0
  fi

  case $1 in *@*) tag="${1#*@}" ;; *) unset tag ;; esac

  # shellcheck disable=SC2154,SC2086
  if ! namer=$(grm_resolve_repo "$1") ||
    ! git -c advice.detachedHead=false clone $clone_opts -q ${tag:+--branch "$tag"} "$namer" "$dir"; then
    echo "clone: clone $clone_opts -q ${tag:+--branch "$tag"} $namer $dir" 1>&2
    return 1
  fi

  printf %s\\n "$dir"
}

grm_diff() {
  git -C "$1" rev-parse &&

    # deleted, modified, other (unstaged)
    git -C "$1" ls-files -dmo --exclude-standard | while read -r file; do
      printf %s\\n "$2$file"
    done &&

    # staged changes
    git -C "$1" diff --cached --name-only | while read -r file; do
      printf %s\\n "$2$file"
    done &&

    # committed but not pushed
    git -C "$1" log --branches --not --remotes --name-only --format="%d" | while read -r file; do
      printf %s\\n "$2$file"
    done
}

# must be called with resolved name
grm_init() {
  _dir="$(grm_resolve_dir "$1")" && mkdir -p -- "$_dir" && git -C "$_dir" init
}

grm_cd() {
  if ! cd "$GRM_HOME" 2>/dev/null; then
    echo "$GRM_HOME directory does not exist" 1>&2
    exit 1
  fi
}

grm_dirs() {
  find "$GRM_HOME" -type d -name ".git" | rev | cut -c 6- | rev | sort
}

grm_find() {
  grm_cd && find . -type d -name ".git" | cut -c 3- | rev | cut -c 6- | rev | sort
}

grm_find_pretty() {
  grm_find | while read -r line; do
    printf "%-16s\t%s\\n" "$(basename -- "$line")" "$(dirname -- "$line")"
  done
}

grm_menu() {
  if [ "$2" ] && grm_find_pretty | cat -n &&
    printf %s "$1 repo number(s): " && read -r _menu_lines; then
    for _menu_line in $_menu_lines; do
      [ "$_menu_line" -eq "$_menu_line" ] 2>/dev/null &&
        _menu_repo=$(grm_find | sed "$_menu_line"'!d') &&
        [ "$_menu_repo" ] &&
        printf %s\\n "$_menu_repo" &&
        g "$2" "$_menu_repo"
    done
    return 0
  fi
}

grm_resolve() {
  for _rn in "$@"; do
    # strip traling .git and leading slash
    _rn="${_rn%.git}"
    case $_rn in /*) _rn=${_rn#/} ;; esac

    case $_rn in
    '')
      echo "resolve: repository name may not be empty" 1>&2 && return 1
      ;;
    .. | */.. | */../* | ../*)
      echo "resolve: $_rn: Can not use .. in repository name" 1>&2 && return 1
      ;;
    */. | */./* | ./*)
      echo "resolve: $_rn: Can not use . in repository name" 1>&2 && return 1
      ;;
    */*/*) printf %s\\n "$_rn" ;;
    */*) printf %s\\n "$GRM_DEFAULT_HOST/$_rn" ;;
    *)
      ! [ "$GRM_DEFAULT_ORG" ] &&
        echo "resolve: $_rn: GRM_DEFAULT_ORG required to resolve repository name" 1>&2 &&
        return 1
      printf %s\\n "$GRM_DEFAULT_HOST/$GRM_DEFAULT_ORG/$_rn"
      ;;
    esac
  done
}

# resolve name and return directory
grm_resolve_name_dir() {
  for _grnd in $(grm_resolve "$@"); do
    grm_resolve_dir "$_grnd"
  done
}

grm_resolve_name_repo() {
  for _grnr in $(grm_resolve "$@"); do
    grm_resolve_repo "$_grnr"
  done
}

# must be called with resolved name
# return local directory for repo
grm_resolve_dir() {
  case $1 in
  https://*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}${1#https://}" ;;
  http://*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}${1#http://}" ;;
  ssh://*) printf %s\\n "${GRM_HOME:+$GRM_HOME/}${1#ssh://}" ;;
  *) printf %s\\n "${GRM_HOME:+$GRM_HOME/}$1" ;;
  esac
}

# must be called with resolved name
# return repository name
grm_resolve_repo() {
  case "${1%@*}.git" in
  *://*) printf %s\\n "${1%@*}.git" ;;
  *) printf %s\\n "$GRM_DEFAULT_SCHEME://${1%@*}.git" ;;
  esac
}

if [ -L "$0" ]; then
  GRM_SCRIPT_HOME="$(dirname -- "$(readlink -- "$0")")"
else
  GRM_SCRIPT_HOME="$(dirname -- "$0")"
fi

GRM_HOME="${GRM_HOME-$(cd "$GRM_SCRIPT_HOME/../../.." && pwd -P)}"
GRM_DEFAULT_SCHEME="${GRM_DEFAULT_SCHEME-https}"
GRM_DEFAULT_HOST="${GRM_DEFAULT_HOST-github.com}"
GRM_EDITOR="${GRM_EDITOR-code}"

g "$@"
