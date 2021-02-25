#!/bin/sh
set -e

if ! command -v git >/dev/null; then
  echo "Error: git is required to install shln." 1>&2
  exit 1
fi

src=${GRM_HOME:-$HOME/src}/github.com/sageify/shln
lnkn=${LNKN_HOME:-$HOME/bin}

! mkdir -p $src &&
  exit 1

if ! git clone -q --depth 1 https://github.com/sageify/shln.git $src; then
  ! [ "$(ls -A $src)" ] && rm -r $src
  exit 1
fi

! mkdir -p $lnkn &&
  exit 1

[ -f $lnkn/lnkn ] && rm $lnkn/lnkn
ln -s $src/lnkn.sh $lnkn/lnkn

[ -f $lnkn/shmod ] && rm $lnkn/shmod
ln -s $src/shmod.sh $lnkn/shmod

[ -f $lnkn/grm ] && rm $lnkn/grm
ln -s $src/grm.sh $lnkn/grm

[ -f $lnkn/shrm ] && rm $lnkn/shrm
ln -s $src/shrm.sh $lnkn/shrm

echo "Linkin (lnkn), Groom (grm), Shmod (shmod), and Shroom (shrm) installed"
if command -v lnkn >/dev/null; then
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
echo "  export PATH=\"$lnkn:\$PATH\""
