# sourced into shln.sh

# for example: shln install github.com/dockcmd/aws v0.0.2

if ! [ $1 ]
then
  echo Usasge: shln install REPOSITORY TAG 1>&2
  exit 1
fi

origin=https://$1.git

if ! [ $2 ]
then
  echo Available tags: 1>&2
  tags $origin 1>&2
  exit 1
fi

err=$(git ls-remote --exit-code $origin refs/tags/$2 2>&1)
if [ $? -eq 2 ]
then
  echo $origin does not contain tag $2 1>&2
  echo Available tags: 1>&2
  tags $origin 1>&2
  exit 1
fi

if [ "$err" ]
then
  echo $err
  exit 1
fi

SHLN_PATH=${SHLN_PATH-~/shln}
dir=$SHLN_PATH/$1

if [ -f "$dir" ] || [ -d "$dir" ]
then
  echo Repository already exists: $repo 1>&2
  exit 1
fi

mkdir -p $dir
git clone --branch $2 --depth 1 $repo $dir 2> /dev/null
if [ $? -ne 0 ] 
then
  rm -rf $dir
  echo Error cloning $1 with tag $2 1>&2
  exit 1
fi

if [ -f $repo/shln.conf ]
then 
  while IFS= read link
  do
    shln ln $link
  done < $repo/shln.conf
else
  ls $repo/*.sh | while read f
  do
    shln ln `basename $f | cut -f 1 -d '.'`
  done
fi
