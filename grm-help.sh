cat <<EOF

Usage:	$(basename $0) COMMAND

Git Commands
 clone   clone a repository
 code    launch visual studio code for repository, cloning if necessary
 diff    show any differences in local repository vs remote
 rm      safely remove repository if no differences with remote
 tags    show remote tags
 pull    pull from remote repository

General Commands
 env     show the groom envinroment variables
 exec    execute any linux command in groom home ($GRM_HOME)
 find    find files in local repositories
 which   locate a repository in groom home ($GRM_HOME)
 help    show this page
 
EOF