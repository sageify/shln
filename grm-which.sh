grm_repo_tag_dir $1
path=$GRM_HOME/$dir

if ! [ -d "$path/.git" ]; then
  echo $path git repository not found 1>&2
  exit 1
fi

echo $path
