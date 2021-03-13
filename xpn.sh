#!/bin/sh
xpn() {
  if ! xpn_name "$1"; then
    echo "xpn: $1: Invalid command name" 1>&2
    return 1
  fi

  pos=1
  while [ $pos -le $# ] && ! [ "$ignore_all" ]; do
    unset split word

    eval 'arg=$'$pos
    case $arg in
    -*=*)
      # -opt=value
      opt="${arg%%=*}"
      if xpn_name "$opt"; then
        val=${arg#*=}
        xpn_sw "$cmd$opt=" "$val" || xpn_sw "$1\\*$opt=" "$val"
      fi
      ;;
    -*)
      # -opt
      if xpn_name "$arg"; then
        xpn_sw "$cmd$arg" || xpn_sw "$1\\*$arg"
      fi
      ;;
    *)
      # cmd
      if ! [ "$ignore_commands" ]; then
        if xpn_name "$arg"; then
          if ! xpn_sw "$cmd$arg" && ! [ "$ignore_all" ]; then
            cmd="$cmd$arg>"
            grep -q -e "^[ /t]*$cmd$" <"$dot_xpn" && ignore_commands=y
          fi
        else
          echo "expn: $cmd ($lastarg): $arg: warning: Invalid command name" 1>&2
        fi
      fi
      ;;
    esac
    lastarg="$arg"

    if [ "$split" ] || [ "$word" ]; then
      if [ $pos -eq 1 ]; then
        set -- $split ${word+"$word"} "${@:(($pos + 1))}"
      else
        set -- "${@:1:(($pos - 1))}" $split ${word+"$word"} "${@:(($pos + 1))}"
      fi
      continue
    fi

    pos=$(($pos + 1))
  done

  # if not dry run, exec (which terminates script)
  ! [ "${dr+x}" ] && exec "$@"

  xpn_escape "$1"
  shift
  for item in "$@"; do
    printf ' '
    if [ "$dr" = l ]; then printf '\\\n'; fi
    xpn_escape "$item"
  done
  printf "\n"
}

xpn_sw() {
  xpn="$(grep -e "^[ /t]*$1[ /t]" <"$dot_xpn" | sed -e "s/^[ /t]*$1[ /t]*//")"
  case $xpn in
  '') return 1 ;;
  '!1') pos=$(($pos + 1)) ;;
  '!*') return 2 ;;
  \`*) word="${xpn#\`*}$2" ;;
  *)
    for item in $xpn; do
      case $item in
      \"* | *\" | \'* | *\')
        echo "xpn: $item: warning: Use \` to prevent splitting.  Quotes are treated as literals" 1>&2
        ;;
      esac
      [ "$word" ] && split="$split $word"
      word=$item
    done
    if [ "$2" ]; then
      word="$word$2"
    fi
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
  e=$(set | grep -e "^a=")
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

#
# Install default expansions
#

dot_xpn="${XPN_CONFIG-$HOME/.xpn}"
xpn "$(basename "$0")" "$@"
