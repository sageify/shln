lnkn_uninstall() {
  ! dir=$(grm which $1) &&
    return 1

  grm rm $1

  ls $LNKN_HOME | while read link; do
    if [ "$dir" = "$(dirname $(readlink $LNKN_HOME/$link))" ]; then
      # any link that references the git directory is removed
      rm $LNKN_HOME/$link
    fi
  done
}

if ! [ $1 ]; then
  echo usage: lnkn uninstall REPOSITORY [REPOSITORY] 1>&2
  exit 1
fi

for repo in "$@"; do
  lnkn_uninstall $repo
done
