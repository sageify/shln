if ! [ "$1" ]; then
  echo "usage: $(basename "$0") pull org/repo[@tag] ..." 1>&2
  echo "       $(basename "$0") pull sageify/sh" 1>&2
  echo "       $(basename "$0") pull sageify/sh@v0.0.1" 1>&2
  exit 1
fi

for repo in "$@"; do
  [ "$repo" ] && dir=$(grm_dir "$repo") && git -C "$dir" pull
done
