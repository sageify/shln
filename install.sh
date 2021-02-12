#!/bin/sh

SHLN_SOURCE_PATH=${SHLN_SOURCE_PATH:-$HOME/.shln}
SHLN_LN_PATH=${SHLN_LN_PATH:-$HOME/bin}

! mkdir -p $SHLN_SOURCE_PATH/github.com/sageify/shln && exit 1
cd $_

if ! git clone --depth 1 https://github.com/sageify/shln.git . 2> /dev/null
then
  echo fail: 1>&2
  echo git clone ${2:+--branch $2} $1 $3 1>&2
  exit 1  
fi

! mkdir -p $SHLN_LN_PATH && exit 1
ln -s $(pwd)/shln.sh $SHLN_LN_PATH/shln
ln -s $(pwd)/shmod.sh $SHLN_LN_PATH/shmod

echo "Links successfully installed to $SHLN_LN_PATH, source to $SHLN_SOURCE_PATH"
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
	echo "  export PATH=\"\$SHLN_LN_PATH:\$PATH\""
	echo "Run 'shln' to get started"
fi
