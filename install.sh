#!/bin/sh

set -e

if ! command -v git >/dev/null 
then
	echo "Error: git is required to install shln." 1>&2
	exit 1
fi

SHPACK_PATH=${SHPACK_PATH:-$HOME/.shpack}
SHLN_PATH=${SHLN_PATH:-$HOME/bin}

! mkdir -p $SHPACK_PATH/github.com/sageify/shln && exit 1
cd $_

if ! git clone --depth 1 https://github.com/sageify/shln.git . 2> /dev/null
then
  echo Error: git clone ${2:+--branch $2} $1 $3 1>&2
  exit 1  
fi

! mkdir -p $SHLN_PATH && exit 1
ln -s $(pwd)/shln.sh $SHLN_PATH/shln
ln -s $(pwd)/shmod.sh $SHLN_PATH/shmod

echo "Links successfully installed to $SHLN_PATH, shln package to $SHPACK_PATH"
if command -v deno >/dev/null
then
	echo "Run 'shln' to get started"
else
	case $SHELL in
	/bin/zsh) 
    shell_profile=".zshrc" ;;
	*) 
    shell_profile=".bash_profile" ;;
	esac
	echo "Manually add the link directory to your \$HOME/$shell_profile (or similar)"
	echo "  export PATH=$SHLN_PATH\":\$PATH\""
	echo "Run 'shln' to get started"
fi
