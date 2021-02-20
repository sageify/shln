. shmod

# it's ok if SHMOD_HOME doesn't exist, might not be any installed yet
! cd $SHMOD_HOME 2>/dev/null && \
  exit 0

find . -mindepth 3 -maxdepth 3 -type d | cut -c 3-