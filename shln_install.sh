# sourced into shln.sh

# Install a shln module:
# shln install dockcmd/aws-sh@v0.0.1
# shln install github.com/dockcmd/aws-sh@v0.0.1

if ! [ $1 ]
then
  echo Usage: shln install REPOSITORY[@BRANCH_TAG]  1>&2
  exit 1
fi

# get repo, dir and tag
. shmod
shmod_repo_tag_dir $1

if ! git ls-remote -h $repo 1> /dev/null
then
  # problem with finding repo
  exit 1
fi

if ! [ $tag ]
then
  echo Repository tag missing: $1 1>&2
  echo Usage: repo@tag
  exit 1
fi

# Add SHLN_PATH to dir.  SHLN_PATH is set in shln.sh from which this should be sourced
dir=$SHLN_PATH/$dir

if [ -f "$dir" ] || [ -d "$dir" ]
then
  echo Repository or file already exists: $dir 1>&2
  exit 1
fi

shmod_clone $repo $tag $dir

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
