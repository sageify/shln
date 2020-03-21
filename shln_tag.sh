# sourced into shln.sh

if ! [ $1 ]
then
  echo Usage: shln tag REPOSITORY 1>&2
  exit 1
fi

tags https://$1.git
