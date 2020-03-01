# sourced into shln.sh

# for example: shln install github.com/dockcmd/aws v0.0.2

SHLN_PATH=${SHLN_PATH-~/shln}

repo=$SHLN_PATH/$1

if [ -f "$repo" ] || [ -d "$repo" ]; then
  echo Repository already exists: $repo
  exit 1
fi

mkdir -p $repo
git clone --branch $2 --depth 1 https://$1.git $repo

if [ -f $repo/shln.conf ]; then 
  while IFS= read link; do
    shln ln $link
  done < $repo/shln.conf
fi
