if ! [ "$1" ]; then
  echo "usage: lnkn grm SOURCE " 1>&2
  exit 1
fi

base="$(basename $1)"
link_name="$LNKN_HOME/${base%.*}"

if [ -f "$link_name" ]; then
  ls -l "$link_name"
  exit 0
fi

if ! count="$(grm find "$1" | head -n 2 | wc -l 2>/dev/null)" || [ "$count" -eq 0 ]; then
  echo "grm: $1: File not found" 1>&2
  exit 1
fi

if [ "$count" -gt 1 ]; then
  echo "grm: multiple sources (limit 10), try 'lnkn grm /$1':" 1>&2
  grm find "$1" | head -n 10 | while read file; do
    printf %s\\n "$file"
  done 1>&2
  exit 1
fi

# link to script
ln -s "$GRM_HOME/$(grm find "$1" | head -n 1)" "$link_name"

# reset cache for where executable found in case link covers an existing executable
hash -r

# output link
ls -l "$link_name"
