# lnkn install dockcmd/aws-sh
# lnkn install github.com/dockcmd/aws-sh@v0.0.1
lnkn_install() {
  # if more than one script, don't link
  if ! dir=$(grm clone $1) || ! script=$(ls $dir/*.sh) ||
      [ $(printf %s "$script" | wc -w) -ne 1 ]; then
    return 1
  fi

  base="$(basename $script)"
  link_name="$LNKN_HOME/${base%.*}"

  ln -s "$script" "$link_name"

  # reset cache for where executable found in case link covers an existing executable
  hash -r

  ls -l "$link_name"
}

if ! [ $1 ]; then
  echo usage: lnkn install REPOSITORY[@BRANCH_TAG] ... 1>&2
  exit 1
fi

for repo in "$@"; do
  lnkn_install $repo
done
