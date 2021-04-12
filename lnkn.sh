#!/bin/sh

lnkn_install() {
  # if more than one script, don't link
  dir=$(grm clone -- "$1") || return $?

  printf %s\\n "$dir"
  grm "$1" -perm +111 | while read -r exe; do
    link="$LNKN_HOME/${exe%.*}"
    [ -L "$link" ] && rm -- "$link"
    ln -s "$dir"/"$exe" "$link"
    lnkn_print "$link"
  done

  # reset cache for where executable found in case link covers an existing executable
  hash -r
}

lnkn_uninstall() {
  dir="$(grm which -- "$1")" || return $?

  grm rm -- "$1" && find "$LNKN_HOME" -maxdepth 1 | while read -r link; do
    # any link that references the git directory is removed
    [ "$dir" = "$(dirname -- "$(readlink -- "$link")")" ] &&
      rm -- "$link"
  done
}

lnkn_exec() {
  cd -- "$LNKN_HOME" && exec "$@"
}

lnkn_print() {
  readlink="$(readlink -- "$1")" &&
    basename="$(basename -- "$readlink")" &&
    dirname="$(dirname -- "$readlink")" || return $?
  case $dirname in
  "$(grm home)"/*) dirname="${dirname#"$(grm home)"/}" ;;
  esac
  printf "%-12s\t%-12s\t%s\\n" "${1#"$LNKN_HOME"/}" "$basename" "$dirname"
}

lnkn_help() {
  cat <<EOF
  _  _       _     _       
 | |(_)     | |   (_)      
 | | _ ____ | |  _ _ ____  
 | || |  _ \| |_/ ) |  _ \ 
 | || | | | |  _ (| | | | |
  \_)_|_| |_|_| \_)_|_| |_|

Usage:	lnkn COMMAND | CUSTOM

Show the current links.  To list in long format, use lnkn -l.

Link Commands
    ls     List links
    mv     Move a link 
    rm     Remove a link
 c, cmd    Add shortcut link to an existing command
 g, grm    Add link to a Groom repository file
 w, which  Print source file location referenced by a link

Git Repsoitory and Link Commands
 install     Clone a new git repository and add default links
 uninstall   Remove git repository and any associated links

Other Commands
 exec     Execute any linux command in $LNKN_HOME  
 home     Print home directory for links
 version  Print the version information
 help     Show this help
EOF
}

readonly LNKN_HOME="${LNKN_HOME-$(dirname -- "$0")}"

case "$1" in
'')
  find "$LNKN_HOME" -maxdepth 1 | sort | while read -r item; do
    [ -L "$item" ] && lnkn_print "$item"
  done
  ;;

cmd | c)
  shift && [ "$1" = -- ] && shift
  ! [ "$2" ] && echo "usage: cmd SOURCE LINK " 1>&2 && exit 1

  link="$LNKN_HOME/$2"
  if [ -f "$link" ]; then
    lnkn_print "$link"
    exit 0
  fi

  source=$(which -- "$1") &&
    # reset cache for where executable found in case link shadows an existing executable
    ln -s "$source" "$link" && hash -r && lnkn_print "$link"
  ;;

exec) shift && cd -- "$LNKN_HOME" && exec "$@" ;;

grm | g)
  shift && [ "$1" = -- ] && shift
  ! [ "$1" ] && echo "usage: lnkn grm SOURCE [LINK] " 1>&2 && exit 1

  base="$(basename -- "$1")" link_name="$LNKN_HOME/${2-${base%.*}}"
  if [ -f "$link_name" ]; then
    lnkn_print "$link_name"
    exit 0
  fi

  if ! count="$(grm find-all "*/$1" | head -n 2 | wc -l 2>/dev/null)" || [ "$count" -eq 0 ]; then
    echo "grm: $1: File not found" 1>&2
    exit 1
  fi

  if [ "$count" -gt 1 ]; then
    echo "grm: multiple sources (limit 10), try 'lnkn grm '*<name>/$1':" 1>&2
    grm find-all "$1" | head -n 10 | while read -r file; do
      printf %s\\n "$file"
    done 1>&2
    exit 1
  fi

  # link to script
  ln -s "$(grm home)/$(grm find-all "*/$1" | head -n 1)" "$link_name" &&
    # reset cache for where executable found in case link covers an existing executable
    hash -r &&
    # output link
    lnkn_print "$link_name"
  ;;

home) printf %s\\n "$LNKN_HOME" ;;

install)
  shift
  if [ "$1" = -n ]; then
    shift && for repo; do
      grm clone-- "$repo"
    done
  else
    for repo; do
      lnkn_install "$repo"
    done
  fi
  ;;

uninstall)
  shift && for repo; do
    lnkn_uninstall "$repo"
  done
  ;;

which | w)
  shift && [ "$1" = -- ] && shift
  [ "${1+_}" ] && for param; do
    [ -L "$LNKN_HOME/$param" ] && printf %s\\n "$(readlink "$LNKN_HOME/$param")"
  done
  ;;

code | ln | ls | mv | nano | rm) lnkn_exec "$@" ;;

version | --version) echo "$(basename -- "$0") version 0.5.0" ;;

help | -h | --help) lnkn_help ;;

-*) echo "lnkn: $1: Option not found" 1>&2 && exit 1 ;;

*) echo "lnkn: $1: Unknown command" 1>&2 && lnkn_help 1>&2 && exit 1 ;;
esac
