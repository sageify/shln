nv() {
  case "$1" in
  "")
    nv grep "$ENVY_PATTERN"
    ;;
  all)
    case "$2" in
    "")
      nv domain all | while read all_domain; do
        nv grep $(nv domain pattern "$all_domain")
      done
      ;;
    unset)
      nv domain all | while read all_unset_domain; do
        nv domain unset "$all_unset_domain"
        unset "ENVY_DOMAIN_$all_unset_domain"
      done
      nv unset "$ENVY_PATTERN"
      unset ENVY_PATTERN
      unset ENVY_CONTEXT
      ;;
    help)
      echo "usage: nv all [ unset | help ]"
      ;;
    *)
      echo "all: $2: Invalid command" 1>&2
      nv all help 1>&2
      return 1
      ;;
    esac
    ;;
  context)
    case "$2" in
    "")
      [ "$ENVY_CONTEXT" ] && echo $ENVY_CONTEXT
      ;;
    set)
      nv context check $3 && [ "$3" ] && export ENVY_CONTEXT="$3"
      ;;
    check)
      check_context=${3-$ENVY_CONTEXT}
      case "$check_context" in
      "")
        echo "context: May not be empty" 1>&2
        return 1
        ;;
      /* | */)
        echo "context: $check_context: Cannot have leading or trailing slash" 1>&2
        return 1
        ;;
      *[![:alnum:]/]*)
        echo "context: $check_context: Invalid path character, can only be alphanumeric" 1>&2
        return 1
        ;;
      esac
      ;;
    help)
      echo "usage: nv context [ set | check [CONTEXT] ]"
      ;;
    *)
      echo "context: $2: Invalid command" 1>&2
      nv context help 1>&2
      return 1
      ;;
    esac
    ;;
  domain)
    if [ -n "${3+x}" ]; then
      case "$2" in
      check)
        case "$3" in
        /* | */ | */*)
          echo "domain: $2: Cannot have leading or trailing slash" 1>$2
          return 1
          ;;
        *[![:alnum:]]*)
          echo "domain: $2: Invalid character, can only be alphanumeric" 1>$2
          return 1
          ;;
        esac
        ;;
      context)
        context_dv=$(nv domain value "$3") && echo ${context_dv%:*}
        ;;
      pattern)
        pattern_dv=$(nv domain value "$3") && echo ${pattern_dv#*:}
        ;;
      unset)
        nv unset "$(nv domain pattern "$3")"
        ;;
      value)
        nv domain check "$3" && echo $(printenv ENVY_DOMAIN_$3)
        ;;
      esac
    else
      case "$2" in
      "")
        ! nv context check && return 1
        case "$ENVY_CONTEXT" in
        */*)
          # domain is the first part of a path in a directory
          echo "${ENVY_CONTEXT%/${ENVY_CONTEXT#*/}}"
          ;;
        esac
        ;;
      all)
        IFS='='
        nv grep '^ENVY_DOMAIN_' | while read key _; do
          echo ${key#ENVY_DOMAIN_}
        done
        ;;
      set)
        set_domain=$(nv domain) && export ENVY_DOMAIN_$set_domain="$ENVY_CONTEXT:$ENVY_PATTERN"
        ;;
      help)
        cat <<EOF
usage: domain COMMAND

General Commands
all   show all active domains
set   set current context and pattern as domain
help  show this help

Domain Commands
check     check if valid name
context   show the context
pattern   show the pattern
unset     unset all environment variables
value     show value of the domain environment variable
EOF
        ;;
      check | context | pattern | unset | value)
        echo "usage: nv domain $2 DOMAIN" 1>&2
        return 1
        ;;
      *)
        echo "domain: $2: Invalid command" 1>&2
        nv domain help 1>&2
        return 1
        ;;
      esac
    fi
    ;;
  env)
    nv grep "^ENVY_"
    ;;
  home)
    echo "$ENVY_HOME"
    ;;
  pattern)
    case "$2" in
    "")
      [ "$ENVY_PATTERN" ] && echo $ENVY_PATTERN
      ;;
    set)
      [ "$3" ] && export ENVY_PATTERN="$3" || unset ENVY_PATTERN
      ;;
    unset)
      nv unset $ENVY_PATTERN
      ;;
    help)
      echo "usage: pattern [ set [PATTERN] | unset ]"
      ;;
    *)
      echo "pattern: $2: Invalid command" 1>&2
      nv pattern help 1>&2
      return 1
      ;;
    esac
    ;;
  grep)
    [ "$2" ] && env | grep -E "$2"
    ;;
  new)
    if ! [ "$2" ]; then
      echo "usage: new PATTERN"
      return 1
    fi
    nv unset "$2"
    export ENVY_PATTERN="$2"
    unset ENVY_CONTEXT
    ;;
  switch)
    ! get_dv=$(nv domain value "$2") && return 1
    if ! [ "$get_dv" ]; then
      echo "switch: "${2:-<root>}": Domain not found" 1>&2
      return 1
    fi
    ENVY_CONTEXT=${get_dv%:*}
    ENVY_PATTERN=${get_dv#*:}
    ;;
  unset)
    IFS='='
    nv grep "$2" | while read key _; do
      unset $key
    done
    ;;
  uninstall)
    nv all unset
    unset ENVY_HOME
    unset -f nv
    ;;
  version) echo "envy version 0.1.1" ;;
  help)
    cat <<EOF
usage:  nv COMMAND

Environment 
 get      add context to current environemnt
 grep     grep all environment to an extended pattern
 put      create or replace stored context
 switch   switch to context of another domain
 unset    unset all environment variables for pattern

Resources
 all       show environments for all domains
 context   show the current context
 domain    show the current domain, all domains, or context
 env       show ENVY_ environment variables
 home      show saved contexts home directory
 pattern   show the pattern for the context
 
Directory Management
 cat     show saved context
 cd      change to context file directory
 cp      copy saved context
 ls      list saved contexts
 mkdir   make directory  
 mv      move saved context
 rm      remove saved context

General Commands
 help        show this help
 uninstall   unset everything and uninstall nv
 version     show nv version
EOF
    ;;
  *)
    if ! [ "$ENVY_HOME" ]; then
      echo "nv: ENVY_HOME must be set" 1>&2
      return 99
    fi

    #
    # These commands require ENVY_HOME to be set.
    #
    case "$1" in
    get)
      get_context=${2-${ENVY_CONTEXT}}
      if ! [ "$get_context" ]; then
        echo 'get: context not set:  Use "nv get CONTEXT"' 1>&2
        return 1
      fi

      get_file="$ENVY_HOME/$get_context"
      if ! [ -f "$get_file" ]; then
        echo "get: $get_file: File not found" 1>&2
        return 1
      fi

      ! nv context set "$get_context" && return 1

      nv domain unset "$(nv domain)"
      . $get_file
      nv domain set
      ;;
    put)
      if ! [ "$ENVY_PATTERN" ]; then
        echo 'put: pattern not set:  Use "nv pattern set" first to set the pattern' 1>&2
        return 1
      fi

      put_context="${2-${ENVY_CONTEXT}}"
      if ! [ "$put_context" ]; then
        echo 'put: context not set:  Use "nv put CONTEXT"' 1>&2
        return 1
      fi

      ! nv context set "$put_context" && return 1

      nv domain set

      put_file="$ENVY_HOME/$ENVY_CONTEXT"
      echo 'export ENVY_PATTERN='\'$(echo $ENVY_PATTERN | sed "s/'/'\\\\''/g")\' >$put_file
      IFS='='
      nv grep "$ENVY_PATTERN" | while read name val; do
        echo "export $name="\'$(echo $val | sed "s/'/'\\\\''/g")\' >>$put_file
      done
      ;;
    cat)
      [ "${2-$ENVY_CONTEXT}" ] && cat "$ENVY_HOME/${2-$ENVY_CONTEXT}"
      ;;
    cd)
      cd "$ENVY_HOME"
      ;;
    cp)
      if ! [ "$2" ] || ! [ "$3" ]; then
        echo "usage: cp SOURCE DEST"
        return 1
      fi
      cp "$ENVY_HOME/$2" "$ENVY_HOME/$3"
      ;;
    ls)
      if [ "${2%-*}" ]; then
        ls "$ENVY_HOME/$2"
      else
        ls $2 "$ENVY_HOME/$3"
      fi
      ;;
    mkdir)
      mkdir -p "$ENVY_HOME/$2"
      ;;
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
    which)
      which="$ENVY_HOME/$2"
      if ! [ -f "$which" ] && ! [ -d "$which" ]; then
        echo "$which not found" 1>&2
        return 1
      fi
      echo "$which"
      ;;
    *)
      echo "nv: $1: Invalid command" 1>&2
      nv help 1>&2
      return 1
      ;;
    esac
    ;;
  esac
}

! [ "$ENVY_HOME" ] && export ENVY_HOME="${2-$HOME/.config/envy}"
[ -f "$ENVY_HOME/$1" ] && nv get "$1"
