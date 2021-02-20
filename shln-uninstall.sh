shpack_uninstall() {
  grm_repo_tag_dir $1

  ls $SHLN_HOME  | while read f
  do
    if [ "$dir" = "$( dirname $(readlink $SHLN_HOME/$f) )" ]
    then
      # any link that references the package directory is removed
      rm $SHLN_HOME/$f
    fi
  done

  dir=$(GRM_HOME=$GRM_HOME grm -rm $1)
  [ $? -ne 0 ] && exit 1
}

if ! [ $1 ]
then
  echo Usage: shln uninstall REPOSITORY [REPOSITORY] 1>&2
  echo        shln uninstall -
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
