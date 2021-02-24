#!/bin/sh

if ! [ -L "$0" ]; then
  echo shln: $(basename $0): Must be a symbolic link
  exit 1
fi

SHLN_SCRIPT_HOME=$(dirname $(readlink "$0"))
SHLN_HOME=$(dirname "$0")

if [ $1 ]; then
  case $1 in
  rm | ls | mv)
    SHLN_SCRIPT=$SHLN_SCRIPT_HOME/shln-exec.sh
    ;;
  *)
    SHLN_SCRIPT=$SHLN_SCRIPT_HOME/shln-$1.sh
    shift
    ;;
  esac
else
  SHLN_SCRIPT=$SHLN_SCRIPT_HOME/shln-help.sh
fi

. $SHLN_SCRIPT "$@"
