if ! [ "$1" ]; then
  echo usage: $(basename "$0") tags org/repo[@tag] 1>&2
  exit 1
fi

grm_set_repo_tag "$1"

git ls-remote --tags "$repo" | while read commit t; do
  basename $t
done
