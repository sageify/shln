if ! [ $1 ]; then
  echo   usage: $(basename $0) clone org/repo[@tag] ... 1>&2
  echo "       "$(basename $0) clone sageify/sh
  echo "       "$(basename $0) clone sageify/sh@v0.0.1
  exit 1
fi

for repo in "$@"; do
  grm_clone $GRM_HOME $repo
done
