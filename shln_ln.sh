set -e

if [ ! "$1" ]
then
  echo "Expecting link name as first argument" 1>&2
  exit 1
fi

# LN_PATH provided by shln.sh
link_name=$SHLN_PATH/$1

if [ -f "$link_name" ]
then
  # link already exists, show
  ls -l $link_name
  exit 0
fi

target=$(find $SHPACK_PATH -name $1.sh 2>/dev/null)

if [ $(echo $target | wc -w) -ge 2 ]
then
  echo "Multiple targets:"  1>&2
  echo $target 1>&2
  exit 1
fi

if [ ! "$target" ]
then
  echo "Target not found in $SHPACK_PATH or a sub folder: $1.sh" 1>&2
  exit 1
fi

# link to script
ln -s "$target" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
