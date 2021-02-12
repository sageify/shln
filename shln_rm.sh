# sourced into shln.sh to get LN_PATH

# remove item from shln folder.
if [ "$1" = "shln" ]; then
  echo Cannot remove link: $1
  exit 1
fi

cd $LN_PATH
rm $1
