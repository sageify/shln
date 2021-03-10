#!/bin/sh
. ../nv.sh

! nv --check && echo "Blank name should resolve"

nv --check "bad name" 2>/dev/null && echo "Should be bad name"