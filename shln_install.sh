# sourced into shln.sh

# Install a shln module:
# shln install github.com/dockcmd/aws v0.0.1
# shln install --deep github.com/dockcmd/misc-sh 

if ! [ $1 ]
then
  echo Usage: shln install [--deep] REPOSITORY [BRANCH_TAG]  1>&2
  exit 1
fi

if [ $1 = "--deep" ] || [ $1 = "-d" ]
then
  shift
else
  shallow="--depth 1"
fi

case $1 in
  *.git )
    echo Repository name should not end with .git: $1 1>&2
    exit 1;;
  https://* )
    repo=$1.git
    dir=$SHLN_PATH/$(echo $1 | cut -c 9-);;
  ssh://* )
    repo=$1.git
    dir=$SHLN_PATH/$(echo $1 | cut -c 7-);;
  */*/* )
    repo="https://$1.git"
    dir=$SHLN_PATH/$1;;
  */* )
    repo="https://github.com/$1.git"
    dir=$SHLN_PATH/github.com/$1;;
  * )
    echo Invalid repository name $1 1>&2
    exit 1;;
esac

if ! git ls-remote -h $repo 1> /dev/null
then
  # problem with finding repo
  exit 1
fi

if [ -f "$dir" ] || [ -d "$dir" ]
then
  echo Repository or file already exists: $dir 1>&2
  exit 1
fi

branch=${2:-master}

mkdir -p $dir

if ! git clone --branch $branch $shallow $repo $dir 2> /dev/null
then
  rm -r $dir
  echo Error cloning branch/tag $branch of repo $repo to $dir 1>&2
  exit 1
fi

if [ -f $dir/shln.conf ]
then 
  while IFS= read link || [ "$link" ]
  do
    shln ln $link
  done < $dir/shln.conf
else
  ls $dir/*.sh | while read f
  do
    shln ln $(basename $f | cut -f 1 -d '.')
  done
fi
