# shmod is a sourced function library

# <repo>@<tag/branch> <file1> <file2>
# import dockcmd/sh@v0.0.2 docker.sh
# 
import() {
  if ! [ $2 ]
  then
    echo File missing: $1 1>&2
    echo Usage: import repo@tag file1 file2 ...
    exit 1
  fi

  ! _source=$(shmod_source $1) && \
    exit 1

  for _script in $2
  do
    . $_source/$_script
  done

  # since shmod.sh is sourced, and import() can't be called in a subprocess,
  # need to get rid of local variables.
  unset _source
  unset _script
}

# <repo>
shmod_source() {
  shmod_repo_tag_dir $1
  
  if ! [ $tag ]
  then
    echo Repository tag missing: $1 1>&2
    echo Usage: repo@tag
    exit 1
  fi

  dir=$SHMOD_PATH/$dir@$tag
  shmod_clone $repo $tag $dir "--depth 1"
  echo $dir
}

# sets the repo, tag, amd dir
# sageify/shmod@v0.0.1
# repo=https://github.com/sageify/shmod.git
# tag=v0.0.1
# dir=github.com/sageify/shmod
shmod_repo_tag_dir() {
  IFS='@' read repo tag << EOF
$1
EOF

  # redefine repo
  case $repo in
  ..|*/..|*/../*|../* )
    echo Can not use .. in repository name: $1 1>&2
    exit 1;;
  *.git )
    echo Repository name should not end with .git: $1 1>&2
    exit 1;;
  https://* )
    dir=$(echo $repo | cut -c 9-)
    repo=$repo.git;;
  ssh://* )
    dir=$(echo $repo | cut -c 7-)
    repo=$repo.git;;
  */*/* )
    dir=$repo
    repo="https://$repo.git";;
  */* )
    dir=$SHMOD_GIT_HOST/$repo
    repo=$SHMOD_GIT_SCHEME://$SHMOD_GIT_HOST/$repo.git;;
  * )
    echo Invalid repository name: $1 1>&2
    exit 1;;
  esac
}

# clone  <repo> <tag> <dir>
shmod_clone() {
  [ -f "$3" ] || [ -d "$3" ] && \
    return

  ! mkdir -p $3 && \
    exit 1

  if ! git clone -q $4 ${2:+--branch $2} $1 $3
  then
    # only remove if empty, might be existing directory
    rm -r $3 2>/dev/null
    exit 1
  fi  
}

# if dryrun (dr) is not assigned, exec cmd, otherwise print cmd
# will not return from this function
run() {
  ! [ $1 ] && \
    exit 0

  # if dr not set, just exec.  exec terminates script
  [ -z ${dr+x} ] && \
    exec "$@"

  if [ "$dr" = l ]
  then
    # dr list in long format unescaped
    for word in "$@"
    do
      echo $word \\
    done
    exit 0
  fi

  echo "$@"
  exit 0
}

# shmod requires git
if ! command -v git >/dev/null 
then
	echo "Error: git is required for shmod." 1>&2
	exit 1
fi

# set shmod environment variables
SHMOD_PATH=${SHMOD_PATH-$HOME/.shmod}
SHMOD_GIT_SCHEME=${SHMOD_GIT_SCHEME-https}
SHMOD_GIT_HOST=${SHMOD_GIT_HOST-github.com}