cat <<EOF

Usage:	shln COMMAND | CUSTOM

Shell link commands.

Commands
 ls        list links
 mv        move a link 
 rm        remove a link
 env       show shln, shmod and grm environments
 gln       add link to a git repository file
 cln       add shortcut link to an existing command
 install   clone a new git repository and add default links
 uninstall remove git repository and any associated links
 version   show the git tag, if any, of the source for a link
 exec      execute any linux command in $SHLN_HOME  

EOF