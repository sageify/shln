#!/bin/sh

lnkn_install() {
  # if more than one script, don't link
  if ! dir=$(grm clone -- "$1") || ! script=$(ls -- "$dir/*.sh") ||
    [ "$(printf %s "$script" | wc -w)" -ne 1 ]; then
    ls -- "$dir"
    exit 1
  fi

  base="$(basename -- "$script")"
  link_name="$lnkn_home/${base%.*}"

  ln -s "$script" "$link_name" &&
    # reset cache for where executable found in case link covers an existing executable
    hash -r &&
    ls -l "$link_name"
}

lnkn_uninstall() {
  ! dir="$(grm which -- "$1")" && exit 1

  grm rm -- "$1" && find "$lnkn_home" -maxdepth 1 | while read -r link; do
    # any link that references the git directory is removed
    [ "$dir" = "$(dirname -- "$(readlink -- "$link")")" ] &&
      rm "$link"
  done
}

lnkn_exec() {
  cd -- "$lnkn_home" && exec "$@"
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
 exec     Execute any linux command in $lnkn_home  
 home     Print home directory for links
 version  Print the version information
 help     Show this help
EOF
}

readonly lnkn_home="${LNKN_HOME-$(dirname -- "$0")}"

case "$1" in
'') lnkn_exec ls ;;

'-l')
  find "$lnkn_home" -maxdepth 1 | sort | while read -r item; do
    [ -L "$item" ] && printf "%-12s\t%s\\n" "${item#"$lnkn_home"/*}" "$(readlink -- "$item")"
  done
  ;;

cmd | c)
  shift && [ "$1" = -- ] && shift
  ! [ "$2" ] && echo "usage: cmd SOURCE LINK " 1>&2 && exit 1

  link=$lnkn_home/$2
  if [ -f "$link" ]; then
    ls -l "$link"
    exit 0
  fi

  source=$(which -- "$1") &&
    # reset cache for where executable found in case link shadows an existing executable
    ln -s "$source" "$link" && hash -r && ls -l "$link"
  ;;

exec) shift && cd -- "$lnkn_home" && exec "$@" ;;

grm | g)
  shift && [ "$1" = -- ] && shift
  ! [ "$1" ] && echo "usage: lnkn grm SOURCE [LINK] " 1>&2 && exit 1

  base="$(basename -- "$1")" link_name="$lnkn_home/${2-${base%.*}}"
  if [ -f "$link_name" ]; then
    ls -l "$link_name"
    exit 0
  fi

  if ! count="$(grm find "*/$1" | head -n 2 | wc -l 2>/dev/null)" || [ "$count" -eq 0 ]; then
    echo "grm: $1: File not found" 1>&2
    exit 1
  fi

  if [ "$count" -gt 1 ]; then
    echo "grm: multiple sources (limit 10), try 'lnkn grm '*<name>/$1':" 1>&2
    grm find "$1" | head -n 10 | while read -r file; do
      printf %s\\n "$file"
    done 1>&2
    exit 1
  fi

  # link to script
  ln -s "$(grm home)/$(grm find "*/$1" | head -n 1)" "$link_name" &&
    # reset cache for where executable found in case link covers an existing executable
    hash -r &&
    # output link
    ls -l "$link_name"
  ;;

home) printf %s\\n "$lnkn_home" ;;

install)
  shift  && for repo; do
    lnkn_install "$repo"
  done
  ;;

uninstall)
  shift && for repo; do
    lnkn_uninstall "$repo"
  done
  ;;

which | w)
  shift && [ "$1" = -- ] && shift
  [ "${1+x}" ] && for param; do
    [ -L "$lnkn_home/$param" ] && printf %s\\n "$(readlink "$lnkn_home/$param")"
  done
  ;;

code | ln | ls | mv | nano | rm) lnkn_exec "$@" ;;

version | --version) echo "$(basename -- "$0") version 0.5.0" ;;

help | -h | --help) lnkn_help ;;

-*) echo "lnkn: $1: Option not found" 1>&2 && exit 1 ;;

*) echo "lnkn: $1: Unknown command" 1>&2 && lnkn_help 1>&2 && exit 1 ;;
esac
