# sourced into shln.sh

set -e

shpack_uninstall() {
  shmod_repo_tag_dir $1

  dir=$SHPACK_PATH/$dir

  if ! [ -d "$dir" ]
  then
    echo fatal: not a package: $dir 1>&2
    exit 1
  fi

  if ! [ -d "$dir/.git" ]
  then
    echo fatal: package is missing git repository: $dir 1>&2
    exit 1
  fi

  cd $dir
  diff=$(git diff --name-only)
  if [ "$diff" ]
  then
    echo "fatal: modified files exist in $dir" 1>&2
    echo $diff 1>&2
    exit 1
  fi

  cd $dir
  diff=$(git log --branches --not --remotes)
  if [ "$diff" ]
  then
    echo "fatal: commits haven't been pushed in $dir" 1>&2
    echo $diff 1>&2
    exit 1
  fi

  ls $SHLN_PATH  | while read f
  do
    if [ "$dir" = "$( dirname $(readlink $SHLN_PATH/$f) )" ]
    then
      # any link that references the package directory is removed
      rm $SHLN_PATH/$f
    fi
  done

  rm -rf $dir
}

if ! [ $1 ]
then
  echo Usasge: shln uninstall REPOSITORY [REPOSITORY] 1>&2
  exit 1
fi

. shmod

if [ "$1" == "-" ]
then
  read args
  for arg in $args shln
  do
    shpack_uninstall $arg
  done
  exit 0
fi

for pack in "$@"
do
  shpack_uninstall $pack
done
