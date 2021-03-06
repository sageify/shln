if ! [ "$1" ]; then
  printf %s\\n "$GRM_HOME"
  exit 0
fi

for repo in "$@"; do
  [ "$repo" ] && grm_which "$repo"
done
