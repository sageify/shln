# sourced into shln.sh

# shln install github.com/dockcmd/aws v0.0.1

SHLN_PATH=${SHLN_PATH-~/shln}

repo=$SHLN_PATH/$1

if [ -f "$repo" ] || [ -d "$repo" ]; then
  echo Repository already exists: $repo
  exit 1
fi

mkdir -p $repo
cd $repo

git clone --branch $2 --depth 1 https://$1.git .

if [ -f shln.conf ]; then 
  while IFS= read link; do
    shln ln $link
  done < shln.conf
fi
