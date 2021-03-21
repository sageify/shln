#!/bin/sh

assert_equals() {
  [ "$1" = "$2" ] && return 0
  echo "assert equals: '$1': found: '$2'${3+": $3"}"
  return 1
}

assert_eq() {
  [ "$1" -eq "$2" ] && return 0
  echo "assert eq: '$1': found: '$2'${3+": $3"}"
  return 1
}

assert_fail() {
  echo "assert fail${1+": $1"}"
  return 1
}

GRM_HOME=$(../grm.sh home)
assert_equals 'github.com/sageify/xxx' "$(../grm.sh resolve "sageify/xxx")"
assert_equals 'github.com/sageify/shln' "$(../grm.sh resolve "sageify/shln")"
assert_equals 'github.com/sageify/shln' "$(../grm.sh resolve "/sageify/shln")"
assert_equals 'github.com/sageify/shln@v1' "$(../grm.sh resolve "sageify/shln@v1")"
assert_equals 'https://github.com/sageify/shln' "$(../grm.sh resolve "https://github.com/sageify/shln")"

assert_equals "$GRM_HOME/github.com/sageify/shln" "$(../grm.sh resolve-d "https://github.com/sageify/shln")"
assert_equals "$GRM_HOME/github.com/sageify/shln@v1" "$(../grm.sh resolve-d "sageify/shln@v1")"

assert_equals 'https://github.com/sageify/shln.git' "$(../grm.sh resolve-r "sageify/shln@v3.0.3")"
