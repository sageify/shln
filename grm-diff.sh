if ! [ $1 ]; then
  repos=$(grm find)
  if [ "$repos" ]; then
    grm diff $repos
  fi
  exit 0
fi

for repo in "$@"; do
  grm_diff $GRM_HOME $repo
done
