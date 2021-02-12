#!/bin/sh

if ! [ -f "$(pwd)/shln.sh" ]
then
  echo Execute from folder that contains shln.sh 1>&2
  exit 1
fi

mkdir -p ~/bin
ln -s $(pwd)/shln.sh ~/bin/shln
ln -s $(pwd)/shmod.sh ~/bin/shmod
