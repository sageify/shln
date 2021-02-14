# sourced into shln.sh

set -e

shpack_uninstall() {
  shmod_repo_tag_dir $1

  dir=$SHPACK_PATH/$dir

  if ! [ -d "$dir/.git" ]
  then
    echo fatal: no git repository at $dir 1>&2
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

if [ "$1" = "-" ]
then
  while read -r line || [ $line ]
  do
    for arg in $line
    do
      shpack_uninstall $arg
    done
  done
  exit 0
fi

for pack in "$@"
do
  shpack_uninstall $pack
done
