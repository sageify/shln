# sourced into shln.sh

if ! [ $1 ]
then
  echo Usasge: shln tags REPOSITORY 1>&2
  exit 1
fi

tags https://$1.git
