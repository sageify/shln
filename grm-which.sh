for repo in "$@"; do
  [ "$repo" ] && grm_which "$repo"
done
