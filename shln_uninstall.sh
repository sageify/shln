# sourced into shln.sh

if ! [ $1 ]
then
  echo Usasge: shln uninstall REPOSITORY 1>&2
  exit 1
fi

. shmod
shmod_repo_tag_dir $1

if [ "$dir" = "$SHLN_PATH/github.com/sageify/shln" ]
then
  echo Must manually uninstall $1
  exit 1
fi

if ! [ -d "$dir/.git" ]
then
  echo Local repository does not exists: $dir
  exit 
  1
fi

if [ -f $dir/shln.conf ]
then 
  while IFS= read link; do
    shln rm $link
  done < $dir/shln.conf
else
  ls $dir/*.sh | while read f
  do
    shln rm `basename $f | cut -f 1 -d '.'`
  done
fi

rm -rf $dir