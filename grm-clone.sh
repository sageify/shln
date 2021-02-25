if ! [ $1 ]; then
  echo usage: $(basename $0) clone org/repo[@tag] ... 1>&2
  echo "       "$(basename $0) clone sageify/sh
  echo "       "$(basename $0) clone sageify/sh@v0.0.1
  exit 1
fi

grm_clone() {
  grm_repo_tag_dir $2

  dir=$1/$dir${tag:+@$tag}

  if [ -d "$dir" ]; then
    echo $dir
    return
  fi

  ! mkdir -p "$dir" &&
    return 1

  if ! git clone -q ${tag:+--branch $tag} $repo $dir 2>/dev/null; then
    ! [ "$(ls -A $dir)" ] && rm -r $dir
    echo clone: $repo: Invalid repository 1>&2
    return 1
  fi

  echo $dir
}

for repo in "$@"; do
  [ $repo ] && grm_clone $GRM_HOME $repo
done
