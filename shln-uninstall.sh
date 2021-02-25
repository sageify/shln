shln_uninstall() {
  ! dir=$(grm which $1) &&
    return 1

  ls $SHLN_HOME | while read link; do
    if [ "$dir" = "$(dirname $(readlink $SHLN_HOME/$link))" ]; then
      # any link that references the git directory is removed
      rm $SHLN_HOME/$link
    fi
  done

  grm rm $1
}

if ! [ $1 ]; then
  echo usage: shln uninstall REPOSITORY [REPOSITORY] 1>&2
  exit 1
fi

for repo in "$@"; do
  shln_uninstall $repo
done
