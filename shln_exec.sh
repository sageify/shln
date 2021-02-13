# sourced into shln.sh

if ! [ $1 ]
then
  echo usage shln exec cmd [arg1] [arg2] ... 1>&2
  exit 1
fi

cmd=$1
shift
exec $SHLN_PATH/$cmd "$@"