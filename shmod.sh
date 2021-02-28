# <repo>@<tag/branch> <file1> <file2>
# import dockcmd/sh@v0.0.2 docker.sh other.sh ...
#
# sources other scripts, must not be called in subprocess
import() {
  if ! [ "$2" ]; then
    echo "import: $1: Must specify at least one file in repository" 1>&2
    exit 1
  fi

  ! _source=$(clone_opts="--depth 1" shrm clone "$1") &&
    exit 1

  shift
  for _script in "$@"; do
    . "$_source/$_script"
  done

  # since shmod.sh is sourced, and import() can't be called in a subprocess,
  # need to get rid of local variables.
  unset _source
  unset _script
}
