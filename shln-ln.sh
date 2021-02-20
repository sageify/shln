if [ ! "$1" ]
then
  echo "usage:  shln -ln" 1>&2
  exit 1
fi

# LN_PATH provided by shln.sh
link_name=$SHLN_HOME/$1

if [ -f "$link_name" ]
then
  # link already exists, show
  ls -l $link_name
  exit 0
fi

target=$(find $GRM_HOME -name $1.sh 2>/dev/null)

if [ $(echo $source | wc -w) -ge 2 ]
then
  echo "multiple source:"  1>&2
  echo $source 1>&2
  exit 1
fi

if [ ! "$source" ]
then
  echo "source not found in $GRM_HOME or a sub folder: $1.sh" 1>&2
  exit 1
fi

# link to script
ln -s "$source" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
