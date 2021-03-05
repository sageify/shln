cat <<EOF
Usage:	lnkn COMMAND | CUSTOM

Linkin commands.

Link Commands
 ls     list links
 mv     move a link 
 rm     remove a link
 cmd    add shortcut link to an existing command
 grm    add link to a Groom repository file
 exec   execute any linux command in $LNKN_HOME  
 env    show Linkin and Groom environments

Git Repsoitory and Link Commands
 install     clone a new git repository and add default links
 uninstall   remove git repository and any associated links
EOF
