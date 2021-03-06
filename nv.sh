nv() {
  case "$1" in
  '') nv grep "$ENVY_PATTERN" ;;
  all)
    case "$2" in
    '')
      for __ in $(nv domain all); do
        nv grep "$(nv domain pattern "$__")"
      done
      ;;
    unset)
      nv context unset
      for __ in $(nv domain all); do
        nv domain unset $__
      done
      ;;
    help) echo "usage: nv all [ unset | help ]" ;;
    *)
      echo "all: $2: Invalid command" 1>&2
      nv all help 1>&2
      return 1
      ;;
    esac
    ;;
  check)
    case "$2" in
    /* | */)
      echo "name: $2: May not have leading or trailing slash" 1>&2
      return 1
      ;;
    *[![:alnum:]/]*)
      echo "name: $2: Can only be alphanumeric" 1>&2
      return 1
      ;;
    */*/*)
      echo "name: $2: May only have one path separator" 1>&2
      return 1
      ;;
    *) return 0 ;;
    esac
    ;;
  context)
    case "$2" in
    all)
      for __ in $(nv domain all); do
        nv domain context $__
      done
      ;;
    resolve)
      nv check "$3" && case "$3" in
      */*) echo $3 ;;
      '') echo nv/default ;;
      *) echo $(nv domain)/$3 ;;
      esac
      ;;
    '')
      # should only fail if envy_context adjusted outside script
      ! nv context resolve "$envy_context" && exit 1
      ;;
    set) __=$(nv context resolve "$3") && envy_context=$__ ;;
    unset)
      nv pattern unset
      unset envy_context
      ;;
    help) echo "usage: nv context [ all | resolve CONTEXT | push | set | unset | help ]" ;;
    *)
      echo "context: $2: Invalid command" 1>&2
      nv context help 1>&2
      return 1
      ;;
    esac
    ;;
  domain)
    case "$2" in
    resolve) nv check "$3" && echo ${3%/*} ;;
    value) __="$(eval 'echo $envy_domain_'$(nv domain resolve "$3"))" && echo "$__" ;;
    context) __="$(nv domain value "$3")" && echo "${__%=*}" ;;
    pattern) __="$(nv domain value "$3")" && echo "${__#*=}" ;;
    '') nv domain resolve $(nv context) ;;
    all)
      set | grep -E '^envy_domain_' | while IFS='=' read key _; do
        echo ${key#envy_domain_}
      done
      ;;
    find)
      find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$3" | while read file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
      ;;
    unset)
      if __="$(nv domain pattern "$3")"; then
        nv unset "$__"
        unset envy_domain_$3
      fi
      return 0
      ;;
    help)
      cat <<EOF
usage: domain COMMAND

General Commands
all    show all active domains
find   show all domains
set    set current context and pattern to domain
help   show this help

Domain Specific Commands
check     check if valid name
context   show the context
pattern   show the pattern
unset     unset all environment variables
value     show value of the domain environment variable
EOF
      ;;
    *)
      echo "domain: $2: Invalid command" 1>&2
      nv domain help 1>&2
      return 1
      ;;
    esac
    ;;
  pattern)
    case "$2" in
    '') [ "$ENVY_PATTERN" ] && printf %s\\n "$ENVY_PATTERN" ;;
    set) [ "$3" ] && export ENVY_PATTERN="$3" || unset ENVY_PATTERN ;;
    all)
      for __ in $(nv domain all); do
        nv domain value $__
      done
      ;;
    unset)
      nv unset "$ENVY_PATTERN"
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
    if ! [ "$2" ] || ! _nv_dv="$(nv domain value "$2")"; then
      return 1
    fi
    nv context set "${_nv_dv%=*}"
    nv pattern set "${_nv_dv#*=}"
    nv context
    ;;
  unset)
    while IFS='=' read __ _; do
      [ "$__" ] && unset "$__"
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
    unset _ __ _nv_context nv_domain _nv_dv _nv_key _nv_file _nv_pattern _nv_value
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
 check       check if a valid context or domain name
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

      for _nv_context in "$@"; do
        if ! [ "$_nv_context" ] || ! _nv_context="$(nv context resolve "$_nv_context")"; then
          return 1
        fi

        _nv_file="$ENVY_HOME/$_nv_context"
        if ! [ -f "$_nv_file" ]; then
          echo "open: $_nv_file: File not found" 1>&2
          return 1
        fi

        ! nv context set "$_nv_context" && return 1

        nv domain unset $(nv domain)

        while IFS='=' read _nv_key _nv_value; do
          case "$_nv_key" in
          ^envy_domain* | ENVY_HOME | envy_context | '') ;;
          *) export $_nv_key="$_nv_value" ;;
          esac
        done <"$_nv_file"

        eval 'envy_domain_'$(nv domain)'="$_nv_context=$(nv pattern)"'
      done
      ;;
    save)
      if ! _nv_pattern=$(nv pattern); then
        echo 'save: pattern not set:  Use "nv pattern set" to set the pattern' 1>&2
        return 1
      fi

      [ "$2" ] && ! nv context set "$2" && return 1

      _nv_domain=$(nv domain)
      _nv_context=$(nv context)

      eval 'envy_domain_'$_nv_domain'="$_nv_context=$_nv_pattern"'

      mkdir -p "$ENVY_HOME/$_nv_domain"

      nv grep "^ENVY_PATTERN=" >"$ENVY_HOME/$_nv_context"
      nv grep "$_nv_pattern" >>"$ENVY_HOME/$_nv_context"
      ;;
    reset)
      nv all unset
      while read __; do
        [ "$__" ] && nv open "$__"
      done <<EOF
$(nv find default)
EOF
      ;;
    cat) cat "$ENVY_HOME/${2-$(nv context)}" ;;
    cd) cd "$ENVY_HOME" ;;
    cp)
      if ! [ "$2" ] || ! [ "$3" ]; then
        echo "usage: cp SOURCE DEST"
        return 1
      fi
      cp "$ENVY_HOME/$2" "$ENVY_HOME/$3"
      ;;
    find)
      find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "*$2" | while read file; do
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
      if ! [ "$2" ]; then
        printf %s\\n "$ENVY_HOME"
        return 0
      fi
      __="$ENVY_HOME/$2"
      if ! [ -f "$__" ] && ! [ -d "$__" ]; then
        echo "$2 not found" 1>&2
        return 1
      fi
      printf %s\\n "$__"
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
  mkdir -p "$ENVY_HOME"
  nv reset
else
  ! [ "$ENVY_HOME" ] && export ENVY_HOME="$HOME/.config/envy"
  mkdir -p "$ENVY_HOME"
fi

# Notes
#
# nv domain and nv context are guaranteed to be alphanumeric with no spaces
# nv domain and nv context always succeed
# nv context can be anything, but must not be empty.
#
