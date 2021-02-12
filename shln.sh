#!/bin/sh

# shln control script, setup environment variables, defer to a shln_[cmd] script

if ! [ -L "$0" ]
then
  echo shln.sh must be called from a symbolic link
  exit 1
fi

# Directory holding the symbolic link names.
SHLN_LN_PATH=$(dirname "$0")

# Directory holding the shell script itself
SCRIPT_PATH=$(dirname $(readlink "$0"))

# Root path to shln source
# assumes shln scripts are in something like github.com/sageify/shln dir
# if not, set SHLN_SOURCE_PATH globally
# we don't use realpath as it isn't available on OSX
SHLN_SOURCE_PATH=${SHLN_SOURCE_PATH-$(cd $SCRIPT_PATH/../../.. && pwd -P)}

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
