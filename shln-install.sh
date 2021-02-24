# sourced into shln.sh

set -e

# Install a shln module:
#
# shln install dockcmd/aws-sh
# shln install github.com/dockcmd/aws-sh@v0.0.1
#
shpack_install() {
  ! dir=$(grm clone $1) &&
    return 1

  ! script=$(ls $dir/*.sh) &&
    return 1

  # if more than one script, don't link
  [ $(echo $script | wc -w) -ne 1 ] &&
    return

  link_name=$SHLN_HOME/$(basename $script | rev | cut -c 4- | rev)

  ln -s "$script" "$link_name"

  # reset cache for where executable found in case link covers an existing executable
  hash -r

  ls -l "$link_name"
}

if ! [ $1 ]; then
  echo Usage: shln install REPOSITORY[@BRANCH_TAG] ... 1>&2
  exit 1
fi

for pack in "$@"; do
  shpack_install $pack
done
