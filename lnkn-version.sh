link_name=$LNKN_HOME/${1-lnkn}

if ! [ -f "$link_name" ]; then
  echo version: $link_name: Link not found 1>&2
  exit 1
fi

cd $(dirname $(readlink "$link_name"))
tag=$(git tag -l --points-at HEAD)
echo ${tag:=HEAD}
