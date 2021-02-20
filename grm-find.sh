if ! [ $1 ]; then
  find . -mindepth 3 -maxdepth 3 -type d | cut -c 3-
  exit 0
fi

shift
grm find -x . -path "*$1" "$@" | cut -c 3-
