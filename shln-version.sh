link_name=$SHLN_HOME/${1-shln}

if ! [ -f "$link_name" ]; then
  echo shln_version: $link_name: Link not found 1>&2
  exit 1
fi

cd $(dirname $(readlink "$link_name"))
tag=$(git tag -l --points-at HEAD)
echo ${tag:=HEAD}
