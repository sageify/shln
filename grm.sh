#!/bin/sh
set -e

if ! [ -L "$0" ]; then
  echo grm: $(basename $0): Must be a symbolic link
  exit 1
fi

# Directory holding this script file
SCRIPT_HOME=$(dirname $(readlink "$0"))

if ! [ $1 ]; then
  cat $SCRIPT_HOME/grm-help.txt
  exit 1
fi

# Root path to shln source
# assumes shln scripts are in something like github.com/sageify/shln dir
# if not, set GRM_HOME globally
# we don't use realpath as it isn't available on OSX
GRM_HOME=${GRM_HOME-$(cd $SCRIPT_HOME/../../.. && pwd -P)}

cd $GRM_HOME

case $1 in
-*)
  # maps to an OPTION
  SCRIPT=$SCRIPT_HOME/grm$1.sh

  if [ ! -f "$SCRIPT" ]; then
    cat $SCRIPT_HOME/grm-help.txt
    exit 1
  fi

  shift
  . $SCRIPT "$@"

  exit 0
  ;;
esac

if ! command -v $1 >/dev/null; then
  cat $SCRIPT_HOME/grm-help.txt
  exit 1
fi

exec "$@"
