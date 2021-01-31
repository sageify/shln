#!/bin/sh

if ! [ $1 ]
then
  # usually run via shln
  echo Usage: shln tag REPOSITORY 1>&2
  exit 1
fi


git ls-remote --tags https://$1.git | while read commit tag
do
  echo $(basename $tag)
done
