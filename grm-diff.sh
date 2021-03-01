usage() {
  echo "usage: $(basename "$0") diff [-a] org/repo[@tag] ..." 1>&2
  echo "       $(basename "$0") diff sageify/sh dockcmd/misc-sh" 1>&2
  echo "       $(basename "$0") diff sageify/sh@v0.0.1" 1>&2
  exit 1
}

! [ "$1" ] && usage

while getopts ":ah" opt; do
  case $opt in
  a)
    grm diff $(grm find)
    exit 0
    ;;
  h) usage ;;
  [?])
    echo "diff: invalid option: -$OPTARG" 1>&2
    usage
    ;;
  esac
done

for repo in "$@"; do
  [ "$repo" ] &&
    path="$(grm_which "$repo")" &&
    dir=$(GRM_HOME= grm_dir "$repo") &&
    grm_diff "$path" "$dir/"
done
