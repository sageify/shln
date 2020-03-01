# sourced into shln.sh

if [ "$1" = "github.com/sageify/shln" ]; then
  echo Cannot uninstall $1
  exit 1
fi

# TODO Check if $1 has .. or . components in it and reject, only want children of SHLN_PATH

SHLN_PATH=${SHLN_PATH-~/shln}

repo=$SHLN_PATH/$1

if ! [ -d "$repo/.git" ]; then
  echo Git repository does not exists: $repo
  exit 1
fi

if [ -f $repo/shln.conf ]; then 
  while IFS= read link; do
    shln rm $link
  done < $repo/shln.conf
fi

rm -rf $repo