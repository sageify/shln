# shellcheck shell=sh

# <repo>@<tag/branch> <file1> <file2>
# import dockcmd/sh@v0.0.2 docker.sh other.sh ...
#
# sources other scripts, must not be called in subprocess
#
# requires shroom "shrm" on path which should be a symbolic link to shrm.sh:
# lnkn grm shrm.sh
#
import() {
  ! [ "$2" ] && echo "import: $1: Must specify at least one file in repository" 1>&2 &&
    exit 1

  ! _repo=$(clone_opts="--depth 1" shrm clone -- "$1") && exit 1

  shift
  for _file in "$@"; do
    # shellcheck source=/dev/null
    ! . "$_repo/$_file" && exit 1
  done

  # since shmod.sh is sourced, import worked, get rid of local variables.
  unset _repo _file
}
