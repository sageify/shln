if ! [ "$1" ]; then
  echo   usage: $(basename "$0") rm org/repo[@tag] ... 1>&2
  echo "       "$(basename "$0") rm sageify/sh
  echo "       "$(basename "$0") rm sageify/sh@v0.0.1
  exit 1
fi

for repo in "$@"; do
  ! dir=$(grm_which "$repo") || ! diff=$(grm_diff "$dir") &&
    exit 1

  if [ "$diff" ]; then
    echo "grm_rm: $dir: Deleted, modified, unstaged, staged, or unpushed files exist:" 1>&2
    echo $diff 1>&2
    exit 1
  fi

  read -p "Remove $dir (y/n): " yn
  if [ "y" = "$yn" ]; then
    rm -rf "$dir"
  fi
done
