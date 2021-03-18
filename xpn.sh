#!/bin/sh

# set split and word environment variables for the provided expansion key
# example: kubectl>g
xpn_option() {
  for key in "$@"; do
    xpn="$(grep -m 1 -e '^[ /t]*'"$key"'[ /t]' "$dot_xpn" | sed -e 's/^[ /t]*'"$key"'[ /t]*//')"
    case $xpn in
    '') continue ;;
    '!c' | '!k') echo "xpn: $key: Option may not have directive" 1>&2 && exit 1 ;;
    esac
    xpn_word
    return 0
  done
}

xpn_command() {
  [ "$command_ignore" ] && return 1
  [ "$command_ignore_next" ] && command_ignore=y
  for key in "$@"; do
    xpn="$(grep -m 1 -e '^[ /t]*'"$key"'[ /t]' "$dot_xpn" | sed -e 's/^[ /t]*'"$key"'[ /t]*//')"
    case $xpn in
    '') continue ;;
    '!c') command_ignore=y && return 0 ;;
    '!k') command_ignore_next=y && return 0 ;;
    esac
    # if expanded, then we don't have a native command
    xpn_word && return 1
    break
  done
  [ "$command_ignore" ] && return 1
  return 0
}

xpn_word() {
  case $xpn in
  '!1') ignore_count=1 && return 1 ;;
  '!*') ignore_count=-1 && return 1 ;;
  \+*)
    add_next=y
    xpn="${xpn#\+*}"
    ;;
  esac
  case $xpn in
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
    ;;
  esac
  return 0
}

xpn_escape() {
  printf %s "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
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
    ! dot_xpn="$(dirname -- "$(readlink -- "$0")")/.xpn" && exit 1
    ! [ -f "$dot_xpn" ] &&
      echo "xpn: Can't find .xpn configuration file" 1>&2 &&
      exit 1
  fi
fi

# Need to put this back into the loop, all processing can go in xpn function
xpn_command "$(basename -- "$0")" && ! [ "$word" ] && echo "xpn: $(basename -- "$0"): Can't find mapping" 1>&2 && exit 1
base="$word" cmd="$word>"
xpn_command "$base"
# grep -q -m 1 -e '^[ /t]*'"$cmd"'[ /t]*$' "$dot_xpn" && command_ignore=y

#
# Main Loop
#

params=1
while [ $params -le $# ]; do
  unset split word add_next

  if [ "$ignore_count" ]; then
    ignore_count=$((ignore_count - 1))
    [ "$ignore_count" -eq 0 ] && unset ignore_count
  else
    case $1 in
    *[![:alnum:]_-]*) ;;
    -? | --*) xpn_option "$cmd$1" "$base:$1" ;;
    -*)
      # -au -> -a -u
      flags=${1#-}
      shift
      while [ "$flags" ]; do
        head=${flags%?}
        set -- "-${flags#$head}" "$@"
        flags="$head"
      done
      continue
      ;;
    *) xpn_command "$cmd$1" && cmd="$cmd$1>" ;;
    esac

    if [ "$word" ]; then
      # xpn() succeeded and we have an expansion for $1, drop it
      shift
      if [ "$add_next" ] && [ $params -le $# ]; then
        # command>-n +name=  "-n jane" becomes "-name=jane"
        word="$word$1"
        # drop parameter added to last word
        shift
      fi
      # shellcheck disable=SC2086
      set -- $split "$word" "$@"
      continue
    fi
  fi
  # no expansion, pass positional parameter through
  lastparam="$1"
  shift
  set -- "$@" "$lastparam"
  params=$((params + 1))
done

# if not a dry run, execute underlying command
# shellcheck disable=SC2154
! [ "${dr+x}" ] && exec "$base" "$@"

# dry run
xpn_escape "$base"
for item in "$@"; do
  printf ' '
  [ "$dr" = l ] && printf '\\\n'
  xpn_escape "$item"
done
printf "\n"
