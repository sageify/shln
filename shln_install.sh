# sourced into shln.sh

# Install a shln module:
# shln install github.com/dockcmd/aws v0.0.1
#

if ! [ $1 ]
then
  echo Usage: shln install REPOSITORY TAG 1>&2
  exit 1
fi

repo=https://$1.git

if ! git ls-remote -h $repo 1> /dev/null
then
  # problem with finding repo
  exit 1
fi

if ! [ $2 ]
then
  # no tag specified
  echo Usage: shln install $1 TAG
  echo tags: 1>&2
  tags $repo 1>&2
  exit 1  
fi

if ! git ls-remote --exit-code $repo refs/tags/$2 > /dev/null 2> /dev/null
then
  echo $repo does not contain tag $2 1>&2
  tags $repo 1>&2
  exit 1
fi

dir=${SHLN_PATH-~/shln}/$1

if [ -f "$dir" ] || [ -d "$dir" ]
then
  echo Repository or file already exists: $dir 1>&2
  exit 1
fi

mkdir -p $dir

if ! git clone --branch $2 --depth 1 $repo $dir 2> /dev/null
then
  rm -rf $dir
  echo Error cloning $1 with tag $2 1>&2
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
    shln ln `basename $f | cut -f 1 -d '.'`
  done
fi
