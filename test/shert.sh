# shellcheck shell=sh

assert_equals() {
  [ "$1" = "$2" ] && return 0
  echo "assert equals: $1: found: $2${3+": $3"}"
  return 1
}

assert_eq() {
  [ "$1" -eq "$2" ] && return 0
  echo "assert eq: $1: found: $2${3+": $3"}"
  return 1
}

assert_empty() {
  [ -z "${1+x}" ] && echo "xpn: missing argument: quote argument" 1>&2 && exit 1
  ! [ "$1" ] && return 0
  echo "assert empty: found: $1${2+": $2"}"
}

assert_fail() {
  echo "assert fail${1+": $1"}"
  return 1
}
