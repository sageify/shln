if ! [ "$1" ]; then
  echo "usage: lnkn gln SOURCE " 1>&2
  exit 1
fi

base=$(basename $1)
link_name=$LNKN_HOME/${base%.*}

if [ -f "$link_name" ]; then
  ls -l $link_name
  exit 0
fi

source=$(grm find $1 2>/dev/null)
grm_home=$(grm exec pwd)

if ! [ "$source" ]; then
  echo "gln: $1: File not found in $grm_home" 1>&2
  exit 1
fi

if [ $(echo $source | wc -w) -ge 2 ]; then
  echo "gln: multiple sources:" 1>&2
  echo $source 1>&2
  exit 1
fi

# link to script
ln -s "$grm_home/$source" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
