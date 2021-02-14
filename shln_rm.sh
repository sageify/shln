set -e

for arg in "$@"
do
  if [ "$arg" = "shln" ] || [ "$arg" = "shmod" ]
  then
    echo fatal: cannot rename link: $arg
    exit 1
  fi
done

cd $SHLN_PATH
rm "$@" 
