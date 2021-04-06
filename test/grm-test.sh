#!/bin/sh
. shmod
import github.com/sageify/shert@v0.0.1 shert.sh

GRM_HOME=$(grm home)
shert_equals 'grm resolve sageify/xxx' github.com/sageify/xxx
shert_equals 'grm resolve sageify/shln' github.com/sageify/shln
shert_equals 'grm resolve /sageify/shln' github.com/sageify/shln
shert_equals 'grm resolve sageify/shln@v1' github.com/sageify/shln@v1
shert_equals 'grm resolve https://github.com/sageify/shln' https://github.com/sageify/shln

shert_equals 'grm resolve-d https://github.com/sageify/shln' "$GRM_HOME/github.com/sageify/shln"
shert_equals 'grm resolve-d sageify/shln@v1' "$GRM_HOME/github.com/sageify/shln@v1"

shert_equals 'grm resolve-r sageify/shln@v3.0.3' https://github.com/sageify/shln.git
