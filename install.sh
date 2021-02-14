#!/bin/sh

set -e

if ! command -v git >/dev/null
then
	echo "Error: git is required to install shln." 1>&2
	exit 1
fi

shpack=${SHPACK_PATH:-$HOME/.shpack}/github.com/sageify/shln
shln=${SHLN_PATH:-$HOME/bin}

! mkdir -p $shpack && \
  exit 1

if ! git clone -q --depth 1 https://github.com/sageify/shln.git $shpack
then
  ! [ "$(ls -A $shpack)" ] && rm -r $shpack
  exit 1
fi

! mkdir -p $shln && \
  exit 1

[ -f $shln/shln ] && rm $shln/shln
ln -s $shpack/shln.sh $shln/shln

[ -f $shln/shmod ] && rm $shln/shmod
ln -s $shpack/shmod.sh $shln/shmod

echo "Links successfully created in $shln to $shpack"
if command -v shln >/dev/null
then
	echo "Run 'shln' to get started"
  exit 0
fi

case $SHELL in
/bin/zsh) 
  shell_profile=".zshrc" ;;
*) 
  shell_profile=".bash_profile" ;;
esac

echo "Manually add the link directory to your \$HOME/$shell_profile (or similar):"
echo "  export PATH=\"$shln:\$PATH\""
echo "Then run 'shln' to get started"