# sourced into shln.sh

if [ ! "$1" ]; then
  echo Expecting link name as first argument 1>&2
  exit 1
fi

link_name=$SHLN_BIN/$1

if ! [ -f "$link_name" ]; then
  echo Link not found $link_name 1>&2
  exit 0
fi

cd $(dirname $(readlink "$link_name"))
git tag -l --points-at HEAD