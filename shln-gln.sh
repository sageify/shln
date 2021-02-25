if ! [ "$1" ]; then
  echo "usage: shln ln SOURCE " 1>&2
  exit 1
fi

base=$(basename $1)
link_name=$SHLN_HOME/${base%.*}

if [ -f "$link_name" ]; then
  ls -l $link_name
  exit 0
fi

source=$(grm find $1 2>/dev/null)
grm_home=$(grm exec pwd)

if ! [ "$source" ]; then
  echo "shln_ln: $1: File not found in $grm_home or a sub folder" 1>&2
  exit 1
fi

if [ $(echo $source | wc -w) -ge 2 ]; then
  echo "shln_ln: multiple sources:" 1>&2
  echo $source 1>&2
  exit 1
fi

# link to script
ln -s "$grm_home/$source" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
