set -e

for arg in "$@"
do
  if [ "$arg" = "shln" ] || [ "$arg" = "shmod" ]
  then
    echo fatal: cannot move link: $arg
    exit 1
  fi
done

cd $SHLN_PATH
mv "$@"
