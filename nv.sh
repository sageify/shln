nv() {
  case "$1" in
  '') nv grep "$ENVY_PATTERN" ;;
  all)
    case "$2" in
    '') (
      nv domain all | while read domain; do
        nv grep "$(nv domain pattern "$domain")"
      done
    ) ;;
    unset)
      nv context unset
      while read _nv_domain; do
        nv domain unset "$_nv_domain"
      done <<EOF
$(nv domain all)
EOF
      ;;
    help) echo "usage: nv all [ unset | help ]" ;;
    *)
      echo "all: $2: Invalid command" 1>&2
      nv all help 1>&2
      return 1
      ;;
    esac
    ;;
  context)
    case "$2" in
    '') [ "$envy_context" ] && nv context check "$envy_context" && printf %s\\n "$envy_context" ;;
    set) nv context check $3 && envy_context="$3" ;;
    check)
      case "$3" in
      '')
        echo "context: May not be empty" 1>&2 && return 1
        ;;
      /* | */)
        echo "context: $3: Cannot have leading or trailing slash" 1>&2 && return 1
        ;;
      *[![:alnum:]/]*)
        echo "context: $3t: Invalid path character, can only be alphanumeric" 1>&2 && return 1
        ;;
      esac
      ;;
    unset)
      nv pattern unset
      _nv_domain=$(nv domain) &&
        [ "$(nv context)" = "$(nv domain context "$_nv_domain")" ] &&
        nv domain unset "$_nv_domain"
      unset envy_context
      ;;
    help) echo "usage: nv context [ set | check [CONTEXT] ]" ;;
    *)
      echo "context: $2: Invalid command" 1>&2
      nv context help 1>&2
      return 1
      ;;
    esac
    ;;
  domain)
    if [ -n "${3+x}" ]; then
      # $3 is set, could be blank
      case "$2" in
      check)
        case "$3" in
        /* | */ | */*)
          echo "domain: $2: Cannot have leading or trailing slash" 1>&2
          return 1
          ;;
        *[![:alnum:]]*)
          echo "domain: $2: Invalid character, can only be alphanumeric" 1>&2
          return 1
          ;;
        esac
        ;;
      context) (dv="$(nv domain value "$3")" && [ "$dv" ] && printf %s\\n "${dv%:*}") ;;
      pattern) (dv="$(nv domain value "$3")" && [ "$dv" ] && printf %s\\n "${dv#*:}") ;;
      unset)
        _nv_dv="$(nv domain value "$3")" &&
          unset ENVY_DOMAIN_$3 &&
          nv unset "${_nv_dv#*:}" &&
          [ "$(nv context)" = "${_nv_dv%:*}" ] && nv pattern unset && unset envy_context
        # unset always succeeds!
        return 0
        ;;
      value)
        nv domain check "$3" && _nv_value=$(printenv ENVY_DOMAIN_$3) &&
          [ "$_nv_value" ] && printf %s\\n "$_nv_value"
        ;;
      esac
    else
      case "$2" in
      '') (
        context=$(nv context) &&
          case "$context" in
          */*)
            # domain is the first part of a path in a context
            printf %s\\n "${context%/${context#*/}}"
            ;;
          esac
      ) ;;
      all)
        IFS='='
        nv grep '^ENVY_DOMAIN_' | while read key _; do
          printf %s\\n "${key#ENVY_DOMAIN_}"
        done
        ;;
      set) _nv_domain=$(nv domain) && export ENVY_DOMAIN_$_nv_domain="$envy_context:$ENVY_PATTERN" ;;
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
  home) printf %s\\n "$ENVY_HOME" ;;
  pattern)
    case "$2" in
    '') [ "$ENVY_PATTERN" ] && printf %s\\n "$ENVY_PATTERN" ;;
    set) [ "$3" ] && export ENVY_PATTERN="$3" ;;
    unset)
      nv unset $ENVY_PATTERN
      unset ENVY_PATTERN
      ;;
    help) echo "usage: pattern [ set [PATTERN] | unset ]" ;;
    *)
      echo "pattern: $2: Invalid command" 1>&2
      nv pattern help 1>&2
      return 1
      ;;
    esac
    ;;
  close) nv context unset ;;
  grep) [ "$2" ] && env | grep -E "$2" ;;
  new)
    if ! [ "$2" ]; then
      echo "usage: new PATTERN"
      return 1
    fi
    nv pattern set "$2"
    nv unset "$2"
    unset envy_context
    ;;
  switch)
    if ! _nv_dv=$(nv domain value "$2"); then
      echo "switch: "${2:-<root>}": Domain not active" 1>&2
      return 1
    fi
    nv context set "${_nv_dv%:*}"
    nv pattern set "${_nv_dv#*:}"
    ;;
  unset)
    IFS='='
    while read _nv_key _nv_value; do
      [ "$_nv_key" ] && unset "$_nv_key"
    done <<EOF
$(nv grep "$2")
EOF
    return 0
    ;;
  uninstall)
    nv all unset
    unset envy_context
    unset ENVY_HOME
    # dangling local environment variables
    unset _nv_domain _nv_dv _nv_file _nv_key _nv_open _nv_pattern _nv_value
    unset -f nv
    ;;
  version) echo "envy version 0.1.1" ;;
  help)
    cat <<EOF
usage:  nv COMMAND

File
 new    create new context
 open   add context to current environemnt
 save   create or replace stored context
 reset  reset environment to default

Environment 
 grep     grep all environment to an extended pattern
 switch   switch to context of another domain
 unset    unset all environment variables for pattern

Resources
 all       show environments for all domains
 context   show the current context
 domain    show the current domain, all domains, or context
 home      show saved contexts home directory
 pattern   show the pattern for the context
 
Directory Management
 cat     show saved context
 cd      change to context directory
 cp      copy saved context
 find    find saved context
 ls      list saved contexts
 mkdir   make directory  
 mv      move saved context
 rm      remove saved context
 which   show full file path to saved context

General Commands
 help        show this help
 uninstall   unset everything and uninstall nv
 version     show nv version
EOF
    ;;
  *)
    if ! [ "$ENVY_HOME" ]; then
      echo "nv: ENVY_HOME must be set" 1>&2
      return 1
    fi

    #
    # These commands require ENVY_HOME to be set.
    #
    case "$1" in
    open)
      shift
      if ! [ "$1" ]; then
        echo 'usage: open CONTEXT' 1>&2
        return 1
      fi

      for _nv_open in "$@"; do
        ! [ "$_nv_open" ] && continue

        _nv_file="$ENVY_HOME/$_nv_open"
        if ! [ -f "$_nv_file" ]; then
          echo "open: $_nv_file: File not found" 1>&2
          return 1
        fi

        ! nv context set "$_nv_open" && return 1

        # if there is an existing domain for the new context, unset it
        _nv_domain=$(nv domain) && nv domain unset "$_nv_domain"

        . $_nv_file

        nv domain set
      done
      ;;
    save)
      if ! _nv_pattern=$(nv pattern); then
        echo 'save: pattern not set:  Use "nv pattern set" to set the pattern' 1>&2
        return 1
      fi

      if [ "$2" ]; then
        ! nv context set "$2" && return 1
        _nv_file="$ENVY_HOME/$2"
      elif ! _nv_file="$ENVY_HOME/$(nv context)"; then
        echo 'usage: save CONTEXT' 1>&2
        return 1
      fi

      # set domain to this context
      nv domain set

      printf "export ENVY_PATTERN=%s\n" $(printf %s "$_nv_pattern" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/") >$_nv_file
      IFS='='
      nv grep "$_nv_pattern" | while read name val; do
        printf "export %s=%s\n" "$name" $(printf %s "$val" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/") >>$_nv_file
      done
      ;;
    reset)
      nv all unset
      while read _nv_open; do
        [ "$_nv_open" ] && nv open "$_nv_open"
      done <<EOF
$(nv find default)
EOF
      return 0
      ;;
    cat)
      [ "${2-$envy_context}" ] && cat "$ENVY_HOME/${2-$envy_context}"
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
    find)
      find "$ENVY_HOME" -maxdepth 2 -type f -path "*$2" | while read file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
      ;;
    ls)
      if [ "${2%-*}" ]; then
        ls "$ENVY_HOME/$2"
      else
        ls $2 "$ENVY_HOME/$3"
      fi
      ;;
    mkdir) mkdir -p "$ENVY_HOME/$2" ;;
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
      _nv_which="$ENVY_HOME/$2"
      if ! [ -f "$_nv_which" ] && ! [ -d "$_nv_which" ]; then
        echo "which: $_nv_which not found" 1>&2
        return 1
      fi
      printf %s\\n "$_nv_which"
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

if [ "$1" = init ]; then
  ! [ "$ENVY_HOME" ] && export ENVY_HOME="${2-$HOME/.config/envy}"
  nv reset
else
  ! [ "$ENVY_HOME" ] && export ENVY_HOME="$HOME/.config/envy"
fi
