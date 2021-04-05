#!/bin/sh

. ./shert.sh

export ENVY_HOME=.config/env
export ENVY_PROFILE_HOME=.config/profile
. ../envy.sh

shert_stdout 'nv home' .config/env
shert_stdout 'nv profile-home' .config/profile

shert_stdout 'nv printenv HELLO' 'literal: ", edge cases: \" \", evaluate: 2, no escape: \n \t, dollar: $, two trailing spaces:  '
shert_stdout 'nv printenv MULTI' 'one 
two '

shert_stdout 'nv pattern -s' 'COLOR|COMMAND_|ENVY_|HOSTNAME$|HOME$|LANG$|LaunchInstanceID$|LOGNAME$|ITERM_|LC_|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VISUAL$|VSCODE_|USER|XPC_|_$|__|APPLICATION_INSIGHTS_|ORIGINAL_XDG_'
shert_stdout 'nv profile' nv

shert_stdout 'nv da' nv
shert_stdout 'nv env' nv/default..
shert_stdout 'nv domain' nv
shert_stdout 'nv name' nv/default
shert_stdout 'nv pattern' .

shert_stdout_not_empty 'nv .'
shert_stdout_not_empty 'nv /'

# save default without any pattern
shert_success 'nv save'

shert_stdout_not_empty 'nv @HELLO'
shert_success 'rm .config/env/nv/default'

shert_success 'nv close -a'
shert_stdout_empty 'nv .'

# unset all environment variables (non shell)
unset -v $(nv grep)

nv .

assert_empty "$(nv .)"

assert_empty "$(nv /)"
assert_not_empty "$(nv %)"

shert_success 'nv work hello SAY$'

assert_equals "nv/hello" "$(nv name)"
assert_equals "SAY$" "$(nv pattern)"

nv export SAY='Hello World!'
assert_equals 'Hello World!' "$(nv SAY)"
assert_equals 'Hello World!' "$(printenv SAY)"
assert_equals '' "$(nv ENVY_HOME)"
shert_stdout 'nv .' 'SAY=Hello World!'
shert_success 'nv save'

# git/john

shert_success 'nv work git/john GIT_'

shert_stdout 'nv name' git/john
shert_fail 'nv SAY'
shert_stdout ' nv / | printenv SAY' 'Hello World!'

nv export GIT_COMMITTER_NAME='John Doe'
nv x GIT_COMMITTER_EMAIL='john@example.com'
nv GIT_AUTHOR_NAME='John Doe'
nv GIT_AUTHOR_EMAIL='john@example.com'
nv GIT_A='one
two'
shert_success 'nv save'

# git/jane

shert_success 'nv new jane GIT_'
shert_stdout_empty 'nv .'

nv GIT_COMMITTER_NAME='Jane Doe'
nv GIT_COMMITTER_EMAIL='jane@example.com'
nv GIT_AUTHOR_NAME='Jane Doe'
nv GIT_AUTHOR_EMAIL='jane@example.com'
nv unset GIT_A
shert_success 'nv save'

assert_empty "$(nv printenv GIT_A)"
shert_stdout ' nv / | printenv SAY' 'Hello World!'

# open john within git domain
shert_success 'nv open john'
shert_stdout 'nv d' git
shert_stdout ' nv / | printenv SAY' 'Hello World!'

shert_stdout 'nv GIT_COMMITTER_NAME' "John Doe"
assert_equals "one
two" "$(nv GIT_A)"

shert_success 'nv domain nv'
assert_equals "Hello World!" "$(nv SAY)"
nv unset SAY

shert_success 'nv work goodbye SAY'
nv x SAY=Goodbye!
assert_equals "Goodbye!" "$(nv SAY)"
shert_success 'nv save'

shert_fail 'nv f--'
shert_fail 'nv fa--'
shert_fail 'nv rt-- 9'
shert_stderr 'nv rt-- 9' 'name: 9: may not have a leading digit'
