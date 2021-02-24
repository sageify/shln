#!/bin/sh
set -e

if ! command -v git >/dev/null; then
  echo "Error: git is required to install shln." 1>&2
  exit 1
fi

src=${GRM_HOME:-$HOME/src}/github.com/sageify/shln
shln=${SHLN_HOME:-$HOME/bin}

! mkdir -p $src &&
  exit 1

if ! git clone -q --depth 1 https://github.com/sageify/shln.git $src; then
  ! [ "$(ls -A $src)" ] && rm -r $src
  exit 1
fi

! mkdir -p $shln &&
  exit 1

[ -f $shln/shln ] && rm $shln/shln
ln -s $src/shln.sh $shln/shln

[ -f $shln/shmod ] && rm $shln/shmod
ln -s $src/shmod.sh $shln/shmod

[ -f $shln/grm ] && rm $shln/grm
ln -s $src/grm.sh $shln/grm


echo "Links successfully created in $shln to $shpack"
if command -v shln >/dev/null; then
  echo "Run 'shln' to get started"
  exit 0
fi

case $SHELL in
/bin/zsh)
  shell_profile=".zshrc"
  ;;
*)
  shell_profile=".bash_profile"
  ;;
esac

echo "Manually add the link directory to your \$HOME/$shell_profile (or similar):"
echo "  export PATH=\"$shln:\$PATH\""
echo "Then run 'shln' to get started"
