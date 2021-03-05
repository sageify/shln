if ! [ "$1" ]; then
  echo "usage: $(basename "$0") code org/repo[@tag] ..." 1>&2
  echo "       $(basename "$0") code sageify/sh tmp" 1>&2
  echo "       $(basename "$0") code sageify/sh@v0.0.1" 1>&2
  exit 1
fi

if ! command -v code >/dev/null; then
  echo "code: Visual studio code not found" 1>&2
  exit 1
fi

for repo in "$@"; do
  [ "$repo" ] && dir="$(grm clone "$repo")" && code "$dir"
done
