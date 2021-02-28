if ! [ "$1" ]; then
  repos=$(grm find)
  if [ "$repos" ]; then
    grm diff $repos
  fi
  exit 0
fi

for repo in "$@"; do
  [ "$repo" ] &&
    dir=$(GRM_HOME= grm_dir "$repo") &&
    path="$(grm_which "$repo")" &&
    grm_diff "$path" "$dir/"
done
