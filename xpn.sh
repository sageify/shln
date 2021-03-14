#!/bin/sh

# set split and word environment variables for the provided expansion key
# example: kubectl>g
xpn() {
  xpn="$(grep -m 1 -e "^[ /t]*$1[ /t]" <"$dot_xpn" | sed -e "s/^[ /t]*$1[ /t]*//")"
  case $xpn in
  \+*)
    add_next=y
    xpn="${xpn#\+*}"
    ;;
  esac
  case $xpn in
  '') return 1 ;;
  '!1') ignore_count=1 ;;
  '!*') ignore_count=-1 ;;
  \`*) word="${xpn#\`*}" ;;
  *)
    for item in $xpn; do
      case $item in
      \"* | *\" | \'* | *\')
        echo "xpn: $item: Warning. Use \` to prevent splitting.  Quotes are treated as literals" 1>&2
        ;;
      esac
      [ "$word" ] && split="$split $word"
      word=$item
    done
    word="$word"
    ;;
  esac
  return 0
}

xpn_name() {
  case $1 in '' | *[![:alnum:]_-]*) return 1 ;; esac
  return 0
}

xpn_escape() {
  # poor man's escaping
  a="$1"
  e=$(set | grep -m 1 -e "^a=")
  printf %s "${e#*=}"
}

# Command Expansion
#
# This script will expand command line options, flags and sub commands per the .xpn
# file in the home directory.  By default, expansions for git, kubectl and terraform
# are created.
#
# For example, 'kc g p' will get expanded to 'kubectrl get po'
#
#
# To use, create a link to this file with a configured command.
# By default, 'g', 'kc', and 'tf' are supported.
#
# ln -s xpn.sh kc
#

# must be a symoblic link to this file
! [ -L "$0" ] &&
  echo "xpn: Must be called with a symbolic link" 1>&2 &&
  echo "     create link, for example: ln -s xpn.sh kc" 1>&2 &&
  exit 1

# current search order: XPN_CONFIG, link directory, $HOME/.xpn, this scripts directory
! dot_xpn="${XPN_CONFIG-$(dirname -- "$0")/.xpn}" && exit 1
if ! [ -f "$dot_xpn" ]; then
  ! dot_xpn="$HOME/.xpn" && exit 1
  if ! [ -f "$dot_xpn" ]; then
    ! dot_xpn="$(dirname -- $(readlink -- "$0"))/.xpn" && exit 1
    ! [ -f "$dot_xpn" ] &&
      echo "xpn: Can't find .xpn configuration file" 1>&2 &&
      exit 1
  fi
fi

! xpn "$(basename -- "$0")" && echo "xpn: $(basename -- "$0"): Can't find mapping" 1>&2 && exit 1
base="$word" cmd="$word>"
grep -q -m 1 -e "^[ /t]*$cmd[ /t]*$" "$dot_xpn" && ignore_commands=y

#
# Main Loop./
#

pos=1
while [ $pos -le $# ]; do
  unset split word add_next

  if [ "$ignore_count" ]; then
    ignore_count=$((ignore_count - 1))
    [ "$ignore_count" -eq 0 ] && unset ignore_count
  else
    case $1 in
    -*) ! xpn_name "$1" || xpn "$cmd$1" || xpn "$base\\*$1" ;;
    *)
      # cmd
      if ! [ "$ignore_commands" ]; then
        if xpn_name "$1"; then
          if ! xpn "$cmd$1"; then
            cmd="$cmd$1>"
            grep -q -m 1 -e "^[ /t]*$cmd[ /t]*$" "$dot_xpn" && ignore_commands=y
          fi
        else
          echo "xpn: $cmd ($lastparam): $1: Warning. Invalid command name" 1>&2
        fi
      fi
      ;;
    esac

    if [ "$word" ]; then
      # xpn() succeeded and we have an expansion for $1
      shift
      if [ "$add_next" ] && [ $pos -le $# ]; then
        word="$word$1"
        shift
      fi
      set -- $split "$word" "$@"
      continue
    fi
  fi

  # no expansion, pass positional parameter through
  lastparam="$1"
  shift
  set -- "$@" "$lastparam"
  pos=$(($pos + 1))
done

#
# Execute or if dry run, print
#

! [ "${dr+x}" ] && exec "$base" "$@"

xpn_escape "$base"
for item in "$@"; do
  printf ' '
  [ "$dr" = l ] && printf '\\\n'
  xpn_escape "$item"
done
printf "\n"
