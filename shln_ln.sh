# sourced into shln.sh

if [ ! "$1" ]; then
  echo "Expecting link name as first argument" 1>&2
  exit 1
fi

link_name=$SHLN_BIN/$1

if [ -f "$link_name" ]; then
  ls -l $link_name
  exit 0
fi

SHLN_PATH=${SHLN_PATH-~/shln}

target=`find $SHLN_PATH -name $1.sh 2>/dev/null`

count=`echo $target | wc -w`
if [ $count -ge 2 ]; then
  echo "Multiple targets: $target" 1>&2
  exit 1
fi

if [ ! "$target" ]; then
  echo "Target not found in $SHLN_PATH or a sub folder: $1.sh" 1>&2
  exit 1
fi

# link to script
ln -s "$target" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
