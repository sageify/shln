cd $GRM_HOME

if [ $1 ]; then
  find -x . -path "*$1" | cut -c 3-
  exit
fi

find -x . -mindepth 3 -maxdepth 3 -type d | cut -c 3-
