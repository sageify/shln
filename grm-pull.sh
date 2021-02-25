if ! [ $1 ]; then
  echo usage: $(basename $0) pull org/repo[@tag] ... 1>&2
  echo "       "$(basename $0) pull sageify/sh
  echo "       "$(basename $0) pull sageify/sh@v0.0.1
  exit 1
fi

grm_pull() {
  grm_repo_tag_dir $1

  dir=$GRM_HOME/$dir${tag:+@$tag}

  if ! cd $dir 2>/dev/null; then
    echo $dir directory does not exist 1>&2
    exit 1
  fi
  
  git pull
}

for repo in "$@"; do
  [ $repo ] && grm_pull $repo
done
