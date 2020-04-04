#!/bin/sh

# list tags
tags() {
  git ls-remote --tags $1 | while read commit tag
  do
    echo $(basename $tag)
  done
}

if ! [ -L "$0" ]
then
  echo shln.sh must be called from a symbolic link
  exit 1
fi

SHLN_BIN=$(dirname "$0")
SCRIPT_PATH=$(dirname $(readlink "$0"))
# assumes shln scripts are in something like github.com/sageify/shln dir
SHLN_PATH=${SHLN_PATH-$(realpath $SCRIPT_PATH/../../..)}

if ! [ $1 ]
then
  # trap missing $1 here as "shift" below might fail on certain platforms
  . $SCRIPT_PATH/shln_help.sh
  exit 1
fi

# maps a command, such as shln ls to shln_ls
SCRIPT=$SCRIPT_PATH/shln_$1.sh

if [ ! -f "$SCRIPT" ]
then
  SCRIPT=$SCRIPT_PATH/shln_help.sh
fi

shift
. $SCRIPT "$@"
