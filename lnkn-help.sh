cat <<EOF

Usage:	lnkn COMMAND | CUSTOM

Linkin commands.

Commands
 ls        list links
 mv        move a link 
 rm        remove a link
 env       show Linkin and Groom environments
 gln       add link to a Groom repository file
 cln       add shortcut link to an existing command
 install   clone a new git repository and add default links
 uninstall remove git repository and any associated links
 version   show the git tag, if any, of the source for a link
 exec      execute any linux command in $LNKN_HOME  

EOF