# shellcheck shell=sh
# shellcheck disable=SC2031

shert_success() {
  eval "$1" >/dev/null && return 0
  printf "assert success: %s: found: %s\n" "$1" "$?"
}

shert_fail() {
  ! eval "$1" >/dev/null 2>&1 && return 0
  printf "assert err: %s: found: 0\n" "$1"
}

shert_stdout() {
  eval "$1" 2>/dev/null | (
    unset __
    while read -r || [ "$REPLY" ]; do
      __="${__+$__
}$REPLY"
    done
    [ "$2" = "$__" ] && return 0
    printf "assert stdout: %s > %s: found: %s\n" "$1" "$2" "$REPLY"
    return 1
  )
}

shert_stderr() {
  eval "$1" 3>&2 2>&1 1>&3- | (
    unset __
    while read -r || [ "$REPLY" ]; do
      __="${__+$__
}$REPLY"
    done
    [ "$2" = "$__" ] && return 0
    printf "assert stderr: %s 2> %s: found: %s\n" "$1" "$2" "$REPLY"
    return 1
  )
}

shert_stdout_empty() {
  eval "$1" | (
    ! read -r && ! [ "$REPLY" ] && return 0
    printf "assert stdout empty: %s: found: %s\n" "$1" "$REPLY"
    return 1
  )
}

shert_stdout_not_empty() {
  eval "$1" | (
    read -r || [ "$REPLY" ] && return 0
    printf "assert stdout not empty: %s: empty\n" "$1"
    return 1
  )
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
