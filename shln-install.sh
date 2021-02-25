# Install a shln module:
#
# shln install dockcmd/aws-sh
# shln install github.com/dockcmd/aws-sh@v0.0.1
#
shln_install() {
  ! dir=$(grm clone $1) &&
    return

  ! script=$(ls $dir/*.sh) &&
    return

  # if more than one script, don't link
  [ $(echo $script | wc -w) -ne 1 ] &&
    return

  base=$(basename $script)
  link_name=$SHLN_HOME/${base%.*}

  ln -s "$script" "$link_name"

  # reset cache for where executable found in case link covers an existing executable
  hash -r

  ls -l "$link_name"
}

if ! [ $1 ]; then
  echo usage: shln install REPOSITORY[@BRANCH_TAG] ... 1>&2
  exit 1
fi

for repo in "$@"; do
  shln_install $repo
done
