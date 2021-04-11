#!/bin/sh
. shmod
import github.com/sageify/shert@v0.0.1 shert.sh

export ENVY_HOME=.config/envy
. envy

shert_equals 'nv home' .config/envy

shert_equals 'nv / printenv HELLO' 'literal: ", edge cases: \" \", evaluate: 2, no escape: \n \t, dollar: $, two trailing spaces:  '
shert_equals 'nv / printenv MULTI' 'one 
two '

shert_equals 'nv pattern -s' 'COLOR|COMMAND_|ENVY_|HOSTNAME$|HOME$|LANG$|LaunchInstanceID$|LOGNAME$|ITERM_|LC_|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VISUAL$|VSCODE_|USER|XPC_|_$|__|APPLICATION_INSIGHTS_|ORIGINAL_XDG_'
shert_equals 'nv profile' nv

shert_equals 'nv da' nv
shert_equals 'nv config' nv/default..
shert_equals 'nv domain' nv
shert_equals 'nv name' nv/default
shert_equals 'nv pattern' .

shert_not_empty 'nv .'
shert_not_empty 'nv /'

# save default without any pattern
shert_success 'nv save'

shert_not_empty 'nv @HELLO'
shert_success 'rm -- "$(nv home)/env/nv/default"'

shert_success 'nv close -a'
shert_empty 'nv .'
shert_empty 'nv /'
shert_not_empty 'nv %'

# set working hello.SAY$
shert_success 'nv work hello SAY$'
shert_equals 'nv name' "nv/hello"
shert_equals 'nv pattern' "SAY$"

nv export SAY='Hello World!'
shert_equals 'nv SAY' 'Hello World!'
shert_equals 'printenv SAY' 'Hello World!'
shert_empty 'nv ENVY_HOME'
shert_equals 'nv .' 'SAY=Hello World!'
shert_success 'nv save'

# git/john

shert_success 'nv work git/john GIT_'

shert_equals 'nv name' git/john
shert_success 'nv SAY'
shert_equals 'nv / printenv SAY' 'Hello World!'

nv export GIT_COMMITTER_NAME='John Doe'
nv x GIT_COMMITTER_EMAIL='john@example.com'
export GIT_AUTHOR_NAME='John Doe'
nv GIT_AUTHOR_EMAIL='john@example.com'
nv GIT_A='one
two'
shert_success 'nv save'

# git/jane

shert_success 'nv new jane GIT_'
shert_empty 'nv .'

nv GIT_COMMITTER_NAME='Jane Doe'
nv GIT_COMMITTER_EMAIL='jane@example.com'
nv GIT_AUTHOR_NAME='Jane Doe'
nv GIT_AUTHOR_EMAIL='jane@example.com'
unset GIT_A
shert_success 'nv save'

shert_empty 'nv printenv GIT_A'
shert_equals ' nv / printenv SAY' 'Hello World!'

# open john within git domain
shert_success 'nv open john'
shert_equals 'nv d' git
shert_equals 'nv / printenv SAY' 'Hello World!'

shert_equals 'nv GIT_COMMITTER_NAME' "John Doe"
shert_equals 'nv GIT_A' "one
two"

shert_success 'nv domain nv'
shert_equals 'nv SAY' "Hello World!"
unset SAY

shert_success 'nv work goodbye SAY'
nv x SAY=Goodbye!
shert_equals 'nv SAY' "Goodbye!"
shert_success 'nv save'

shert_fail 'nv f--'
shert_fail 'nv fa--'
shert_fail 'nv rt-- 9'
shert_stderr 'nv rt-- 9' 'name: 9: may not have a leading digit'

shert_fail 'nv domain blah'
