#!/bin/sh

if ! [ $1 ]
then
  # usually run via shln
  echo Usage: shln tag REPOSITORY 1>&2
  exit 1
fi

. shmod
shmod_repo_tag_dir $1

git ls-remote --tags $repo | while read commit tag
do
  echo $(basename $tag)
done
