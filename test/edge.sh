assertEquals() {
  ! [ "$1" = "$2" ] &&
    printf "expecting: '%s': found: '%s'%s\n" "$1" "$2" "${3+": $3"}" &&
    return 1
}

export XPN_CONFIG="edge.xpn"

assertEquals '[Hello World]' "$(p -b "Hello World")"
assertEquals '[Hello World]' "$(p -b -word)"
assertEquals '[Hello][World]' "$(p -b -split)"
assertEquals '[Hello][World]' "$(p -b "-split")"

assertEquals '[-split Yall]' "$(p -b "-split Yall")"
assertEquals '[Hello][World][Yall]' "$(p -b -split Yall)"

assertEquals '[Hello][World][Hello World]' "$(p -b -lines)"

assertEquals '[edge][case]' "$(p -b -dang)"
assertEquals '[edge][case]' "$(p -b "-dang")"

assertEquals '[edge][case][edge][case]' "$(p -b -dang edge case)"
assertEquals '[-dang edge case]' "$(p -b "-dang edge case")"

assertEquals '[edge][case=]' "$(p -b -dang=)"
assertEquals '[edge][case=edge][case]' "$(p -b -dang=edge case)"
assertEquals '[edge][case=edge case]' "$(p -b "-dang=edge case")"
assertEquals '[edge][case=edge case]' "$(p -b -dang="edge case")"

assertEquals '[edge case=edge][case]' "$(p -b -dangword=edge case)"
assertEquals '[edge case=edge][case]' "$(p -b -dangword=edge case)"

assertEquals '[   ]' "$(p -b -spaces)"