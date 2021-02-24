if ! [ $1 ]; then
  echo Usage: $(basename $0) rm org/repo[@tag] ... 1>&2
  echo examples:
  echo grm rm sageify/sh
  echo grm rm sageify/sh@v0.0.1
  exit 1
fi

for repo in "$@"; do
  grm_repo_tag_dir $1
  dir=$dir${tag:+@$tag}
  path=$GRM_HOME/$dir

  ! diff=$(grm_diff_path_dir $path $dir) &&
    exit 1

  if [ "$diff" ]; then
    echo grm_rm: $repo: Deleted, modified, unstaged, staged, or unpushed files exist 1>&2
    echo $diff 1>&2
    exit 1
  fi

  read -p "Remove $path (y/n): " yn
  if [ "y" = "$yn" ]; then
    echo rm -rf \""$path"\"
  fi
done
