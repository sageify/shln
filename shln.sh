#!/bin/sh

if [ -L "$0" ]; then
  export SHLN_BIN=`dirname "$0"`
  dest=`readlink -f "$0"`
  export SCRIPT_DIR=`dirname "$dest"`
else
  echo shln.sh must be called from a symbolic link
  exit 1
fi

if [ ! $1 ]; then
  # trap missing $1 here as "shift" below might fail on certain platforms
  $SCRIPT_DIR/shln_help.sh
  exit
fi

# maps a command, such as shln ls to shln_ls
script=$SCRIPT_DIR/shln_$1.sh

if [ ! -f "$script" ]; then
  script=$SCRIPT_DIR/shln_help.sh
fi

shift
. $script "$@"
