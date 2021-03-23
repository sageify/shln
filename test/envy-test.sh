#!/bin/sh

. shert.sh

export ENVY_HOME=.config 
. envy

assert_equals nv "$(nv profile)"
assert_equals nv/ "$(nv name)"
assert_equals . "$(nv pattern)"
assert_equals 'COLOR|COMMAND_|ENVY_|HOSTNAME=|HOME=|LANG=|LaunchInstanceID=|LOGNAME=|ITERM_|LC_|OLDPWD=|PATH=|PWD=|SECURITYSESSIONID=|SHELL=|SHLVL=|SSH_|TERM=|TERM_|TMPDIR=|VSCODE_|USER|XPC_|_=|__|APPLICATION_INSIGHTS_|ORIGINAL_XDG_' "$(nv exclude)"
assert_empty "$(nv env)"

nv gu .

assert_empty "$(nv .)"

! nv new nv/hello SAY= && assert_fail "nv new"
assert_equals "nv/hello" "$(nv name)"
assert_equals "SAY=" "$(nv pattern)"

nv set SAY='Hello World!'

assert_equals 'Hello World!' "$(nv printenv SAY)"
assert_equals 'Hello World!' "$(printenv SAY)"
assert_equals '.config' "$(printenv ENVY_HOME)"
assert_equals '' "$(nv printenv ENVY_HOME)"

assert_equals "SAY=Hello World!" "$(nv .)"

nv save

nv new git/john GIT_
nv set GIT_COMMITTER_NAME='John Doe'
nv set GIT_COMMITTER_EMAIL='john@example.com'
nv set GIT_AUTHOR_NAME='John Doe'
nv set GIT_AUTHOR_EMAIL='john@example.com'
nv save

nv new jane GIT_
nv set GIT_COMMITTER_NAME='Jane Doe'
nv set GIT_COMMITTER_EMAIL='jane@example.com'
nv set GIT_AUTHOR_NAME='Jane Doe'
nv set GIT_AUTHOR_EMAIL='jane@example.com'
nv save

# open john within git domain
nv open john
assert_equals "John Doe" "$(nv printenv GIT_COMMITTER_NAME)"

nv cd nv
assert_equals "Hello World!" "$(nv printenv SAY)"

nv new goodbye SAY=
nv set SAY=Goodbye!
assert_equals "Goodbye!" "$(nv printenv SAY)"
nv save
