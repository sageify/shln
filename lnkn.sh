#!/bin/sh

if ! [ -L "$0" ]; then
  echo "lnkn: $(basename $0): Must be a symbolic link" 1>&2
  exit 1
fi

LNKN_SCRIPT_HOME="$(dirname $(readlink "$0"))"
LNKN_HOME="$(dirname "$0")"

if [ "$1" ]; then
  case "$1" in
  rm | ls | mv | ln)
    LNKN_SCRIPT="$LNKN_SCRIPT_HOME/lnkn-exec.sh"
    ;;
  *)
    LNKN_SCRIPT="$LNKN_SCRIPT_HOME/lnkn-$1.sh"
    if ! [ -f "$LNKN_SCRIPT" ]; then
      echo "lnkn: $1: Command not found" 1>&2
      . "$LNKN_SCRIPT_HOME/lnkn-help.sh" 1>&2
      exit 1
    fi
    shift
    ;;
  esac
else
  LNKN_SCRIPT="$LNKN_SCRIPT_HOME/lnkn-help.sh"
fi

. "$LNKN_SCRIPT" "$@"
