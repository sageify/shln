cat <<EOF
Usage:	$(basename $0) COMMAND

Git Commands
 clone   clone a repository
 diff    show any differences in local repository vs remote
 pull    pull from remote repository
 rm      safely remove repository if no differences with remote
 tags    show remote tags

General Commands
 code    launch visual studio code for repository, cloning if necessary
 env     show the groom envinroment variables
 exec    execute any linux command in groom home ($GRM_HOME)
 find    find files in local repositories
 home    print home directory
 which   locate a repository in groom home ($GRM_HOME)
 help    show this page
EOF
