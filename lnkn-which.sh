if ! [ $1 ]; then
  echo $LNKN_HOME
  exit 0
fi

file="$LNKN_HOME/$1"
if ! [ -L "$file" ]; then
  echo "which: $1 not found or not a link" 1>&2
  exit 1
fi

printf %s\\n "$(readlink "$file")"
