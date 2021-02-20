if ! [ $1 ]; then
  echo Usage: $(basename $0) -clone org/repo[@tag] [home] 1>&2
  echo examples:
  echo ghm -clone sageify/sh tmp
  echo ghm -clone sageify/sh@v0.0.1
  exit 1
fi

. shmod
grm_clone $1 ${2-$GRM_HOME}