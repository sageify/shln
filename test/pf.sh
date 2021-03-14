assert_equals() {
  ! [ "$1" = "$2" ] &&
    printf "assert: '%s': found: '%s'%s\n" "$1" "$2" "${3+": $3"}" &&
    return 1
}

assert_eq() {
  ! [ "$1" -eq "$2" ] &&
    printf "assert: '%s': found: '%s'%s\n" "$1" "$2" "${3+": $3"}" &&
    return 1
}

fail() {
  echo "fail: $1" && return 1
}

assert_equals '[Hello World]' "$(./pf -b "Hello World")"
assert_equals '[Hello World]' "$(./pf -b -word)"
assert_equals '[Hello][World]' "$(./pf -b -split)"
assert_equals '[Hello][World]' "$(./pf -b "-split")"

assert_equals '[-split Yall]' "$(./pf -b "-split Yall")"
assert_equals '[Hello][World][Yall]' "$(./pf -b -split Yall)"

assert_equals '[Hello][World][Hello World]' "$(./pf -b -lines)"

assert_equals '[edge][case]' "$(./pf -b -dang)"
assert_equals '[edge][case]' "$(./pf -b "-dang")"

assert_equals '[edge][case][edge][case]' "$(./pf -b -dang edge case)"
assert_equals '[-dang edge case]' "$(./pf -b "-dang edge case")"

assert_equals '[edge][case=]' "$(./pf -b -dangcase)"
assert_equals '[edge][case=edge]' "$(./pf -b -dangcase edge)"
assert_equals '[edge][case=edge][case]' "$(./pf -b -dangcase edge case)"
assert_equals '[-dangcase edge case]' "$(./pf -b "-dangcase edge case")"
assert_equals '[edge][case=edge case]' "$(./pf -b -dangcase "edge case")"

assert_equals '[edge case=]' "$(./pf -b -dangword)"
assert_equals '[edge case=edge][case]' "$(./pf -b -dangword edge case)"

assert_equals '[   ]' "$(./pf -b -spaces)"
assert_equals '[Hello `World]' "$(./pf -b -tilde)"

assert_equals '[edge][case][-ignore-rest][-dang][-dang]' "$(./pf -b -dang -ignore-rest -dang -dang)"
assert_equals '[edge][case][-ignore-next][-dang][edge][case]' "$(./pf -b -dang -ignore-next -dang -dang)"
