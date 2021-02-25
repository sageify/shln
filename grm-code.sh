if ! [ $1 ]; then
  echo usage: $(basename $0) code org/repo[@tag] ... 1>&2
  echo "       "$(basename $0) code sageify/sh tmp
  echo "       "$(basename $0) code sageify/sh@v0.0.1
  exit 1
fi

if ! command -v code >/dev/null; then
  echo "grm_code: visual studio code not found" 1>&2
  exit 1
fi

for repo in "$@"; do
  if dir=$(grm clone "$repo"); then
    code $dir
  fi
done
