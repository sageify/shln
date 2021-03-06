usage() {
  echo "usage: $(basename "$0") diff [-ah] org/repo[@tag] ..."
  echo "       $(basename "$0") diff sageify/sh dockcmd/misc-sh"
  echo "       $(basename "$0") diff sageify/sh@v0.0.1"
}

if ! [ "$1" ]; then
  usage
  exit 0
fi

while getopts ":ah" opt; do
  case $opt in
  a)
    grm find | while read repo; do grm diff "$repo"; done
    exit 0
    ;;
  h)
    usage
    exit 0
    ;;
  [?])
    echo "diff: invalid option: -$OPTARG" 1>&2
    usage 1>&2
    exit 1
    ;;
  esac
done

for repo in "$@"; do
  [ "$repo" ] &&
    path="$(grm_which "$repo")" &&
    dir="$(GRM_HOME= grm_dir "$repo")" &&
    grm_diff "$path" "$dir/"
done
