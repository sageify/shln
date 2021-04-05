# shellcheck shell=sh
# shellcheck disable=SC2031

shert_success() {
  eval "$1" >/dev/null 2>&1 && return 0
  printf "assert success: %s: found: %s\n" "$1" "$?"
}

shert_fail() {
  ! eval "$1" >/dev/null 2>&1 && return 0
  printf "assert err: %s: found: 0\n" "$1"
}

shert_stdout() {
  eval '__="$('"$1"')"'
  [ "$2" = "$__" ] && return 0
  printf "assert stdout: %s > %s: found: %s\n" "$1" "$2" "$__"
  return 1
}

shert_stderr() {
  eval '__="$('"$1"' 2>&1)"'
  [ "$2" = "$__" ] && return 0
  printf "assert stderr: %s 2> %s: found: %s\n" "$1" "$2" "$__"
  return 1
}

shert_stdout_empty() {
  eval '__="$('"$1"')"'
  ! [ "$__" ] && return 0
  printf "assert stdout empty: %s: found: %s\n" "$1" "$__"
  return 1
}

shert_stdout_not_empty() {
  eval '__="$('"$1"')"'
  [ "$__" ] && return 0
  printf "assert stdout not empty: %s: empty\n" "$1"
  return 1
}

assert_equals() {
  [ "$1" = "$2" ] && return 0
  printf "assert equals: %s: found: %s%s\n" "$1" "$2" "${3+": $3"}"
  return 1
}

assert_eq() {
  [ "$1" -eq "$2" ] && return 0
  printf "assert eq: %s: found: %s%s\n" "$1" "$2" "${3+": $3"}"
  return 1
}

assert_empty() {
  [ -z "${1+x}" ] && echo "xpn: missing argument: quote argument" 1>&2 && exit 1
  ! [ "$1" ] && return 0
  printf "assert empty: found: %s%s\n" "$1" "${2+": $2"}"
}

assert_not_empty() {
  [ -z "${1+x}" ] && echo "xpn: missing argument: quote argument" 1>&2 && exit 1
  [ "$1" ] && return 0
  printf "assert not empty: empty: %s\n" "$2"
}
