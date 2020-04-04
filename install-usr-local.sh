#!/bin/sh

if ! [ -f "$(pwd)/shln.sh" ]
then
  echo Execute from folder that contains shln.sh 1>&2
  exit 1
fi

sudo mkdir -p /usr/local/shln
sudo chown $USER /usr/local/shln
ln -s $(pwd)/shln.sh /usr/local/shln/shln
