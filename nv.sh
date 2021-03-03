nv() {
  case "$1" in
  "") [ "$ENVY_PATTERN" ] && env | grep -E "$ENVY_PATTERN" ;;
  context)
    if [ "$2" ]; then
      export ENVY_CONTEXT="$2"
    else
      [ "$ENVY_CONTEXT" ] && echo $ENVY_CONTEXT
    fi
    ;;
  env) env | grep -E "^ENVY_" ;;
  grep) env | grep -E "$2" ;;
  home) echo "$ENVY_HOME" ;;
  pattern)
    if [ "$2" ]; then
      export ENVY_PATTERN="$2"
    else
      [ "$ENVY_PATTERN" ] && echo $ENVY_PATTERN
    fi
    ;;
  unload)
    nv unset
    unset ENVY_CONTEXT
    unset ENVY_PATTERN
    ;;
  unset)
    ! [ "${2-$ENVY_PATTERN}" ] &&
      return 0
    IFS=
    env | grep -E "${2-$ENVY_PATTERN}" | while read kv; do
      unset $(echo $kv | cut -f1 -d"=")
    done
    ;;
  uninstall)
    unset ENVY_HOME
    unset ENVY_CONTEXT
    unset ENVY_PATTERN
    unset -f nv
    ;;
  help)
    cat <<EOF
usage:  nv COMMAND

Environment Commands
 context    show the current context
 env        show ENVY_ environment variables
 grep       grep environment to extended pattern
 home       show saved contexts home directory
 pattern    show the pattern for the context
 unload     unset environment variables, context and pattern
 unset      unset environment variables

Context File Management
 cat   show saved context
 cd    change to context file directory
 cp    copy saved context
 load  load context
 ls    list saved contexts    
 mv    move saved context
 rm    remove saved context
 save  save context

General Commands
 help       show this help
 uninstall  unset environment variables, context, pattern and nv
EOF
    ;;
  *)
    if ! [ "$ENVY_HOME" ]; then
      echo "nv: ENVY_HOME must be set" 1>&2
      return 99
    fi

    case "$1" in
    load)
      context=${2-${ENVY_CONTEXT-default}}
      file="$ENVY_HOME/$context"
      if ! [ -f "$file" ]; then
        echo "load: $file: File not found" 1>&2
        return 1
      fi

      nv unload
      nv context "$context"
      . $file
      ;;
    save)
      if ! [ "$ENVY_PATTERN" ]; then
        echo 'save: grep pattern not set:  Use "nv pattern" first to set grep pattern' 1>&2
        return 1
      fi

      nv context "${2-${ENVY_CONTEXT-default}}"
      file="$ENVY_HOME/$ENVY_CONTEXT"
      echo 'export ENVY_PATTERN='\'$(echo $ENVY_PATTERN | sed "s/'/'\\\\''/g")\' >$file
      IFS='='
      env | grep -E "$ENVY_PATTERN" | while read name val; do
        echo "export $name="\'$(echo $val | sed "s/'/'\\\\''/g")\' >>$file
      done
      ;;
    cat) [ "${2-$ENVY_CONTEXT}" ] && cat "$ENVY_HOME/${2-$ENVY_CONTEXT}" ;;
    cd) cd "$ENVY_HOME" ;;
    cp)
      if ! [ "$2" ] || ! [ "$3" ]; then
        echo "usage: cp SOURCE DEST"
        return 1
      fi
      cp "$ENVY_HOME/$2" "$ENVY_HOME/$3"
      ;;
    ls) ls "$ENVY_HOME/$2" ;;
    mv)
      if ! [ "$2" ] || ! [ "$3" ]; then
        echo "usage: mv SOURCE DEST"
        return 1
      fi
      mv "$ENVY_HOME/$2" "$ENVY_HOME/$3"
      ;;
    rm)
      if ! [ "$2" ]; then
        echo "usage: rm FILE"
        return 1
      fi
      rm "$ENVY_HOME/$2"
      ;;
    *)
      echo "env: $1: Invalid command" 1>&2
      nv help
      return 1
      ;;
    esac
    ;;
  esac
}

! [ "$ENVY_HOME" ] && export ENVY_HOME="${2-$HOME/.config/envy}"
[ -f "$ENVY_HOME/$1" ] && nv load "$1"
