! [ "$1" ] && exit 1

for repo in "$@"; do
  [ "$repo" ] && grm_which "$repo"
done
