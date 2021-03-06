if ! [ "$1" ]; then
  echo "usage: $(basename "$0") clone org/repo[@tag] ..." 1>&2
  echo "       $(basename "$0") clone sageify/sh" 1>&2
  echo "       $(basename "$0") clone sageify/sh@v0.0.1" 1>&2
  exit 1
fi

grm_clone() {
  # not doing grm_which. directoy does not need to exist
  ! dir="$(grm_dir "$1")" && return 1

  if [ -d "$dir" ]; then
    # not currently validating as a real directory, allows shmod to run faster
    printf %s\\n "$dir"
    return 0
  fi

  grm_set_repo_tag "$1"
  if ! git -c advice.detachedHead=false clone $clone_opts -q ${tag:+--branch "$tag"} "$repo" "$dir"; then
    echo "clone: $clone_opts -q ${tag:+--branch "$tag"} "$repo" "$dir 1>&2
    return 1
  fi

  printf %s\\n "$dir"
}

for repo in "$@"; do
  [ "$repo" ] && grm_clone "$repo"
done
