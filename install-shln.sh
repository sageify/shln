#!/bin/sh

sudo mkdir /usr/local/shln
sudo chown $USER /usr/local/shln
ln -s $(pwd)/shln.sh /usr/local/shln/shln
