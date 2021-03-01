usage() {
  echo "usage: $(basename "$0") pull [-ah] org/repo[@tag] ..." 1>&2
  echo "       $(basename "$0") pull sageify/sh dockcmd/misc-sh" 1>&2
  echo "       $(basename "$0") pull sageify/sh@v0.0.1" 1>&2
  exit 1
}

! [ "$1" ] && usage

while getopts ":ah" opt; do
  case $opt in
  a)
    grm pull $(grm find)
    exit 0
    ;;
  h) usage ;;
  [?])
    echo "pull: invalid option: -$OPTARG" 1>&2
    usage
    ;;
  esac
done

for repo in "$@"; do
  [ "$repo" ] && dir=$(grm_dir "$repo") && git -C "$dir" pull
done
