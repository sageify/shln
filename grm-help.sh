cat <<EOF

Usage:	$(basename $0) COMMAND

Git Commands
 clone   clone a repository
 code    launch visual studio code for repository, cloning if necessary
 diff    show any differences in local repository vs remote
 rm      safely remove repository if no differences with remote
 tags    show remote tags

General Commands
 env     show the groom envinroment variables
 exec    execute any linux command in $GRM_HOME
 find    find local repositories
 help    show this page
 
EOF