#!/bin/sh

if [ -f "$ENVY_HOME/.nvrc" ]; then
  echo "# envy run commands:  nv code @@/.nvrc"
  printf "cat > %s <<__nvrc-eof__ \n" "$ENVY_HOME/.nvrc"
  cat "$ENVY_HOME/.nvrc"
  echo __nvrc-eof__
else
  echo "No .nvrc"
fi

if [ -f "$ENVY_HOME/profile/${ENVY_PROFILE-nv}" ]; then
  echo
  echo "# envy profile"
  printf "cat > %s <<__profile-eof__ \n" "$ENVY_HOME/profile/${ENVY_PROFILE-nv}"
  cat "$ENVY_HOME/profile/${ENVY_PROFILE-nv}"
  echo __profile-eof__
else
  echo "No ENVY_PROFILE file"
fi

# nv not available in subshell, use exports
echo
echo "# environment variables"
printf "ENVY_HOME=%s\n" "$ENVY_HOME"
printf "ENVY_PROFILE=%s\n" "$ENVY_PROFILE"
printf "ENVY_SHELL=%s\n" "$ENVY_SHELL"
printf "ENVY_TEMPLATE_HOME=%s\n" "$ENVY_TEMPLATE_HOME"
printf "GRM_HOME=%s\n" "$(grm home)"
printf "LNKN_HOME=%s\n" "$(lnkn home)"
printf "SHRM_HOME=%s\n" "$(shrm home)"
