# sourced into shln.sh to get LN_PATH

set -x

# remove item from shln folder.
if [ "$1" = "shln" ]; then
  echo fatal: cannot remove link: $1
  exit 1
fi

if ! cd $SHLN_LN_PATH
then
  echo fatal: no such directory: $SHLN_LN_PATH
  exit 1
fi

rm "$@" 
