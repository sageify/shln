#!/bin/sh

if ! [ -L "$0" ]; then
  echo lnkn: $(basename $0): Must be a symbolic link
  exit 1
fi

LNKN_SCRIPT_HOME=$(dirname $(readlink "$0"))
LNKN_HOME=$(dirname "$0")

if [ $1 ]; then
  case $1 in
  rm | ls | mv | ln)
    LNKN_SCRIPT=$LNKN_SCRIPT_HOME/lnkn-exec.sh
    ;;
  *)
    LNKN_SCRIPT=$LNKN_SCRIPT_HOME/lnkn-$1.sh
    shift
    if ! [ -f "$LNKN_SCRIPT" ]; then
      LNKN_SCRIPT=$LNKN_SCRIPT_HOME/lnkn-help.sh
    fi
    ;;
  esac
else
  LNKN_SCRIPT=$LNKN_SCRIPT_HOME/lnkn-help.sh
fi

. $LNKN_SCRIPT "$@"
