# sourced into shln.sh

# for example: shln install github.com/dockcmd/aws v0.0.2

if [ "$1" = "github.com/sageify/shln" ]; then
  echo Cannot uninstall $1
  exit 1
fi

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