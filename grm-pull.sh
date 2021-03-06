usage() {
  echo "usage: $(basename "$0") pull [-ah] org/repo[@tag] ..."
  echo "       $(basename "$0") pull sageify/sh dockcmd/misc-sh"
  echo "       $(basename "$0") pull sageify/sh@v0.0.1"
}

if ! [ "$1" ]; then
  usage
  exit 0
fi

while getopts ":ah" opt; do
  case $opt in
  a)
    grm find | while read repo; do grm pull "$repo"; done
    exit 0
    ;;
  h)
    usage
    exit 0
    ;;
  [?])
    echo "pull: invalid option: -$OPTARG" 1>&2
    usage 1>&2
    exit 1
    ;;
  esac
done

for repo in "$@"; do
  [ "$repo" ] && dir="$(grm_dir "$repo")" && git -C "$dir" pull
done
