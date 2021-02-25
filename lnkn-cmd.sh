if ! [ "$2" ]; then
  echo "usage: lnkn cmd SOURCE LINK " 1>&2
  echo "       lnkn cmd kubectrl kc" 1>&2
  exit 1
fi

link=$LNKN_HOME/$2

if [ -f "$link" ]; then
  ls -l $link
  exit 0
fi

! source=$(which $1) &&
  exit 1

ln -s "$source" "$link"

# reset cache for where executable found in case link shadows an existing executable
hash -r

ls -l "$link"
