if ! [ $1 ]; then
  echo usage: $(basename $0) tags org/repo[@tag] 1>&2
  exit 1
fi

grm_repo_tag_dir $1

git ls-remote --tags $repo | while read commit tag; do
  basename $tag
done
