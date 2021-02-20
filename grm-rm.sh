set -e

if ! [ $1 ]; then
  echo Usage: $(basename $0) -rm org/repo[@tag] 1>&2
  echo examples:
  echo grm -rm sageify/sh
  echo grm -rm sageify/sh@v0.0.1
  exit 1
fi

. shmod
grm_repo_tag_dir ${1%.git}

dir=${GRM_HOME-~}/$dir
if [ "$PWD" = "$dir" ] || [ "$HOME" = "$dir" ] || [ "/" = "$dir" ]; then
  echo grm -rm: $dir: Invalid directory 1>&2
  exit 1
fi

if ! [ -d "$dir" ]
then
  echo grm -rm: $dir: No such directory 1>&2
  exit 1
fi

cd $dir

if ! [ -d ".git" ]
then
  echo grm -rm: $dir.git: No such directory 1>&2
  exit 1
fi

diff=$(git diff --name-only)
if [ "$diff" ]
then
  echo grm -rm: $dir: Modified files exist 1>&2
  echo $diff 1>&2
  exit 1
fi

diff=$(git log --branches --not --remotes)
if [ "$diff" ]
then
  echo grm -rm: $dir: Unpushed commits 1>&2
  echo $diff 1>&2
  exit 1
fi

rm -rf $dir
echo $dir