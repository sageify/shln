# sourced into shln.sh

link_name=$SHLN_BIN/${1-shln}

if ! [ -f "$link_name" ]; then
  echo Link not found $link_name 1>&2
  exit 1
fi

cd $(dirname $(readlink "$link_name"))
git tag -l --points-at HEAD