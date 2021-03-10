assertEquals() {
  ! [ "$1" = "$2" ] && printf "expecting: '%s': found: '%s': %s\n" "$1" "$2" "${3-Not equal}" && return 1
}

fatal() {
  echo $1
  return 1
}

assertEquals "nv/default" "$(nv -en nv)" "First check"
nv --new '^SAY='
export SAY='Hello World!'
nv -s
assertEquals "nv/default" "$(nv -en nv)" "Second check"

! nv -c && fatal "close expected"

