# sourced into shln.sh

# remove item from shln folder.
if [ "$1" = "shln" ]; then
  echo Cannot remove link: $1
  exit 1
fi

cd $SHLN_BIN
rm $1
