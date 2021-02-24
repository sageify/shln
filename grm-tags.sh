if ! [ $1 ]; then
  echo Usage: grm -tag REPOSITORY 1>&2
  exit 1
fi

grm_repo_tag_dir $1

git ls-remote --tags $repo | while read commit tag; do
  echo "$(basename $tag)"
done
