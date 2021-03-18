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

assert_equals '[Hello World]' "$(./pf -b "Hello World")"
assert_equals '[Hello World]' "$(./pf -b -w)"
assert_equals '[Hello World]' "$(./pf -bw)"
assert_equals '[Hello][World]' "$(./pf -bs)"
assert_equals '[Hello][World]' "$(./pf -b "-s")"

assert_equals '[-s Yall]' "$(./pf -b "-s Yall")"
assert_equals '[Hello][World][Yall]' "$(./pf -bs Yall)"

assert_equals '[Hello][World][Hello World]' "$(./pf -b --lines)"

assert_equals '[edge][case]' "$(./pf -b --dang)"
assert_equals '[edge][case]' "$(./pf -b "--dang")"

assert_equals '[edge][case][edge][case]' "$(./pf -b --dang edge case)"
assert_equals '[--dang edge case]' "$(./pf -b "--dang edge case")"

assert_equals '[edge][case=]' "$(./pf -b --dangcase)"
assert_equals '[edge][case=edge]' "$(./pf -b --dangcase edge)"
assert_equals '[edge][case=edge][case]' "$(./pf -b --dangcase edge case)"
assert_equals '[--dangcase edge case]' "$(./pf -b "--dangcase edge case")"
assert_equals '[edge][case=edge case]' "$(./pf -b --dangcase "edge case")"

assert_equals '[edge case=]' "$(./pf -b --dangword)"
assert_equals '[edge case=edge][case]' "$(./pf -b --dangword edge case)"

assert_equals '[   ]' "$(./pf -b --spaces)"
assert_equals '[Hello `World]' "$(./pf -b -t)"

assert_equals '[edge][case][--ignore-rest][--dang][--dang]' "$(./pf -b --dang --ignore-rest --dang --dang)"
assert_equals '[edge][case][--ignore-next][--dang][edge][case]' "$(./pf -b --dang --ignore-next --dang --dang)"

assert_equals '[all]' "$(./pf -b --all)"
