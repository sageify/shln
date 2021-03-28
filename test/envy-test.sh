#!/bin/sh

. shert.sh

export ENVY_HOME=.config
. envy

nv f-- && assert_fail "empty find"
nv fa-- && assert_fail "empty find"


nv rt 9 2>/dev/null && assert_fail "Started with a number"

assert_equals 'literal: ", edge cases: \" \", evaluate: 2, no escape: \n \t, dollar: $, two trailing spaces:  ' "$(nv printenv HELLO)"
assert_equals "one 
two " "$(nv printenv MULTI)"

assert_equals nv "$(nv profile)"
assert_equals nv/default "$(nv name)"
assert_equals . "$(nv pattern)"
assert_equals 'COLOR|COMMAND_|ENVY_|HOSTNAME$|HOME$|LANG$|LaunchInstanceID$|LOGNAME$|ITERM_|LC_|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VISUAL$|VSCODE_|USER|XPC_|_$|__|APPLICATION_INSIGHTS_|ORIGINAL_XDG_' "$(nv pattern -s)"
assert_empty "$(nv da)"

nv unset -a

assert_empty "$(nv .)"

! nv new nv/hello SAY$ && assert_fail "nv new"
assert_equals "nv/hello" "$(nv name)"
assert_equals "SAY$" "$(nv pattern)"

nv export SAY='Hello World!'

assert_equals 'Hello World!' "$(nv SAY)"
assert_equals 'Hello World!' "$(printenv SAY)"
assert_equals '' "$(nv ENVY_HOME)"
assert_equals '.config' "$(printenv ENVY_HOME)"

assert_equals "SAY=Hello World!" "$(nv .)"

nv save

nv new git/john GIT_
nv export GIT_COMMITTER_NAME='John Doe'
nv x GIT_COMMITTER_EMAIL='john@example.com'
nv GIT_AUTHOR_NAME='John Doe'
nv GIT_AUTHOR_EMAIL='john@example.com'
nv GIT_A='one
two'
nv save

nv new jane GIT_
nv GIT_COMMITTER_NAME='Jane Doe'
nv GIT_COMMITTER_EMAIL='jane@example.com'
nv GIT_AUTHOR_NAME='Jane Doe'
nv GIT_AUTHOR_EMAIL='jane@example.com'
nv unset GIT_A
nv save

assert_empty "$(nv printenv GIT_A)"

# open john within git domain
nv open john

assert_equals "John Doe" "$(nv GIT_COMMITTER_NAME)"
assert_equals "one
two" "$(nv GIT_A)"

nv switch nv
assert_equals "Hello World!" "$(nv SAY)"
nv unset SAY

nv new goodbye SAY
nv x SAY=Goodbye!
assert_equals "Goodbye!" "$(nv SAY)"
nv save
