#!/bin/sh

l() {
  case "$1" in
  '') l ls ;;
  cmd | c | -c)
    shift
    ! [ "$2" ] && echo "usage: cmd SOURCE LINK " 1>&2 && return 1

    link=$LNKN_HOME/$2
    if [ -f "$link" ]; then
      ls -l "$link"
      return 0
    fi

    source=$(which "$1") &&
      # reset cache for where executable found in case link shadows an existing executable
      ln -s "$source" "$link" && hash -r && ls -l "$link"
    ;;
  env)
    echo LNKN_HOME=$LNKN_HOME
    grm env
    ;;
  grm | g | -g)
    shift
    ! [ "$1" ] && echo "usage: lnkn grm SOURCE " 1>&2 && return 1

    base="$(basename $1)"
    link_name="$LNKN_HOME/${2-${base%.*}}"

    if [ -f "$link_name" ]; then
      ls -l "$link_name"
      exit 0
    fi

    if ! count="$(grm find "*/$1" | head -n 2 | wc -l 2>/dev/null)" || [ "$count" -eq 0 ]; then
      echo "grm: $1: File not found" 1>&2
      return 1
    fi

    if [ "$count" -gt 1 ]; then
      echo "grm: multiple sources (limit 10), try 'lnkn grm '*<name>/$1':" 1>&2
      grm find "$1" | head -n 10 | while read file; do
        printf %s\\n "$file"
      done 1>&2
      return 1
    fi

    # link to script
    ln -s "$(grm w)/$(grm find "*/$1" | head -n 1)" "$link_name" &&
      # reset cache for where executable found in case link covers an existing executable
      hash -r &&
      # output link
      ls -l "$link_name"
    ;;

  install)
    shift
    for repo in "$@"; do
      lnkn_install "$repo"
    done
    ;;

  uninstall)
    shift
    for repo in "$@"; do
      lnkn_uninstall "$repo"
    done
    ;;

  which | w | -w)
    shift
    if ! [ $1 ]; then
      printf %s\\n "$LNKN_HOME" && return 0
      return $?
    fi

    file="$LNKN_HOME/$1"
    if ! [ -L "$file" ]; then
      echo "which: $1 not found or not a link" 1>&2
      exit 1
    fi

    printf %s\\n "$(readlink "$file")"
    ;;
  rm | ls | mv | ln) l exec "$@" ;;
  exec) shift && cd $LNKN_HOME && exec "$@" ;;
  -h)
    cat <<EOF
Usage:	lnkn COMMAND | CUSTOM

Linkin commands.

Link Commands
 ls     list links
 mv     move a link 
 rm     remove a link
 cmd    add shortcut link to an existing command
 grm    add link to a Groom repository file
 exec   execute any linux command in $LNKN_HOME  
 env    show Linkin and Groom environments
 which  show source file location for a link

Git Repsoitory and Link Commands
 install     clone a new git repository and add default links
 uninstall   remove git repository and any associated links
EOF
    ;;
  -* | --*) echo "lnkn: $1: Option not found" 1>&2 && return 1 ;;
  *) echo "lnkn: $1: Unknown command" 1>&2 && l -h 1>&2 && return 1 ;;

  esac
}

lnkn_install() {
  # if more than one script, don't link
  if ! dir=$(grm clone $1) || ! script=$(ls $dir/*.sh) ||
    [ $(printf %s "$script" | wc -w) -ne 1 ]; then
    ls $dir
    return 1
  fi

  base="$(basename $script)"
  link_name="$LNKN_HOME/${base%.*}"

  ln -s "$script" "$link_name" &&
    # reset cache for where executable found in case link covers an existing executable
    hash -r &&
    ls -l "$link_name"
}

lnkn_uninstall() {
  ! dir="$(grm which $1)" && return 1

  grm rm "$1" && ls "$LNKN_HOME" | while read link; do
    # any link that references the git directory is removed
    [ "$dir" = "$(dirname $(readlink $LNKN_HOME/$link))" ] &&
      rm "$LNKN_HOME/$link"
  done
}

LNKN_HOME="${LNKN_HOME-$(dirname "$0")}"

l "$@"
