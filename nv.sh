nv() {
  case "$1" in
  '') nv grep "$ENVY_PATTERN" ;;
  -a)
    for __ in $(nv name -ad); do
      nv grep "$(nv domain pattern "$__")"
    done
    ;;
  all)
    case "$2" in
    '')
      for __ in $(nv name -ad); do
        nv grep "$(nv domain pattern "$__")"
      done
      ;;
    unset)
      nv pattern unset
      unset envy_context
      for __ in $(nv name -ad); do
        nv domain unset $__
      done
      ;;
    esac
    ;;
  # move to context once context removed
  name)
    case "$2" in
    -n)
      case "$3" in
      /* | */)
        echo "name: $3: May not have leading or trailing slash" 1>&2
        return 1
        ;;
      *[![:alnum:]/_]*)
        echo "name: $3: May only be alphanumeric or underscore" 1>&2
        return 1
        ;;
      */*/*)
        echo "name: $3: May only have one path separator" 1>&2
        return 1
        ;;
      *) return 0 ;;
      esac
      ;;
    -c | '')
      nv name -n "$3" && case "$3" in
      */*) echo $3 ;;
      '')
        if [ "$envy_context" ]; then
          nv name -c "$envy_context"
        else
          echo nv/default
        fi
        ;;
      *) echo $(nv domain)/$3 ;;
      esac
      ;;
    -d)
      nv name -n "$3" && case "$3" in
      */*) echo ${3%/*} ;;
      '')
        if [ "$envy_context" ]; then
          nv name -d "$envy_context"
        else
          echo nv
        fi
        ;;
      *) echo $3 ;;
      esac
      ;;
    -s) __=$(nv name -c "$3") && envy_context=$__ && echo $__ ;;
    # All Implementations
    -a | -ac | -ca )
      for __ in $(nv name -ad); do
        nv domain context $__
      done
      ;;
    -ad | -da )
      set | grep -E '^envy_domain_' | while IFS='=' read key _; do
        echo ${key#envy_domain_}
      done
      ;;
    -h) echo "usage: resolve [-c[a]] [-d[a]] [-n] [-h] [-s] name" ;;
    *)
      echo "resolve: $2: Invalid option" 1>&2
      nv name -h 1>&2
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
    *[![:alnum:]/_]*)
      echo "name: $2: May only be alphanumeric or underscore" 1>&2
      return 1
      ;;
    */*/*)
      echo "name: $2: May only have one path separator" 1>&2
      return 1
      ;;
    *) return 0 ;;
    esac
    ;;
  close)
    nv pattern unset
    nv domain unset $(nv domain)
    unset -v envy_context
    nv switch nv
    ;;
  context)
    case "$2" in
    '') nv name -c "$envy_context" ;;
    resolve)
      nv name -n "$3" && case "$3" in
      */*) echo $3 ;;
      '')
        if [ "$envy_context" ]; then
          nv name -c "$envy_context"
        else
          echo nv/default
        fi
        ;;
      *) echo $(nv domain)/$3 ;;
      esac
      ;;
    all)
      for __ in $(nv name -ad); do
        nv domain context $__
      done
      ;;
    set) __=$(nv name -c "$3") && envy_context=$__ && echo $__ ;;
    help) echo "usage: context [ all | resolve CONTEXT | push | set | unset | help ]" ;;
    *)
      echo "context: $2: Invalid command" 1>&2
      nv name -h 1>&2
      return 1
      ;;
    esac
    ;;
  domain)
    case "$2" in
    '') nv domain resolve "$envy_context" ;;
    resolve)
      nv name -n "$3" && case "$3" in
      */*) echo ${3%/*} ;;
      '')
        if [ "$envy_context" ]; then
          nv domain resolve "$envy_context"
        else
          echo nv
        fi
        ;;
      *) echo $3 ;;
      esac
      ;;
    value)
      [ "$3" ] && __="$(eval 'echo $envy_domain_'$(nv domain resolve "$3"))" &&
        [ "$__" ] && echo "$__"
      ;;
    context) __="$(nv domain value "$3")" && echo "${__%=*}" ;;
    pattern) __="$(nv domain value "$3")" && echo "${__#*=}" ;;
    all)
      set | grep -E '^envy_domain_' | while IFS='=' read key _; do
        echo ${key#envy_domain_}
      done
      ;;
    unset)
      ! __="$(nv domain pattern "$3")" && return 1
      nv unset "$__"
      unset -v envy_domain_$3
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
  grep) [ "$2" ] && env | grep -E "$2" ;;
  new)
    nv pattern unset
    nv pattern set "${2-$(nv domain pattern $(nv domain))}"
    nv domain unset $(nv domain)
    ;;
  pattern)
    case "$2" in
    '') [ "$ENVY_PATTERN" ] && printf %s\\n "$ENVY_PATTERN" ;;
    set) [ "$3" ] && export ENVY_PATTERN="$3" || unset ENVY_PATTERN ;;
    all)
      for __ in $(nv name -ad); do
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
  switch)
    ! _nv_dv="$(nv domain value "$2")" && return 1
    nv name -s "${_nv_dv%=*}"
    nv pattern set "${_nv_dv#*=}"
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
    unset -v ENVY_HOME
    # dangling local environment variables
    unset -v _ __ _nv_context nv_domain _nv_dv _nv_key _nv_file _nv_pattern _nv_value
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
      ! [ "$1" ] && set -- $(nv name)

      for __ in "$@"; do
        ! nv name -s "$__" && return 1
        nv domain unset $(nv domain)
        nv pattern set

        while IFS='=' read _nv_key _nv_value; do
          case "$_nv_key" in
          ENVY_HOME | ^envy_domain* | envy_context | '') ;;
          *)
            export $_nv_key="$_nv_value"
            ;;
          esac
        done <"$ENVY_HOME/$(nv name)"

        # new ENVY_PATTERN should be exported in above read
        eval 'envy_domain_'$(nv domain)'="$(nv name)=$(nv pattern)"'
      done
      ;;
    save)
      if [ "$2" ]; then
        ! nv name -s "$2" && return 1
      else
        nv name
      fi

      eval 'envy_domain_'$(nv domain)'="$(nv name)=$(nv pattern)"'

      mkdir -p "$ENVY_HOME/$(nv domain)"
      echo "ENVY_PATTERN=$(nv pattern)" >"$ENVY_HOME/$(nv name)"
      nv grep "$(nv pattern)" >>"$ENVY_HOME/$(nv name)"
      ;;
    reset)
      nv all unset
      while read __; do
        [ "$__" ] && nv open "$__"
      done <<EOF
$(nv find context default)
EOF
      ;;
    cat) cat "$ENVY_HOME/$(nv name -c "$2")" ;;
    cd) cd "$ENVY_HOME" ;;
    cp)
      if ! [ "$2" ] || ! [ "$3" ]; then
        echo "usage: cp SOURCE DEST"
        return 1
      fi
      cp "$ENVY_HOME/$2" "$ENVY_HOME/$3"
      ;;
    find)
      case "$2" in
      '')
        find "$ENVY_HOME/$(nv domain)" -mindepth 1 -maxdepth 1 -type f | while read file; do
          printf %s\\n "${file#$ENVY_HOME/$(nv domain)/}"
        done
        ;;
      domain)
        find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$3" | while read file; do
          printf %s\\n "${file#$ENVY_HOME/}"
        done
        ;;
      context)
        find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "*$3" | while read file; do
          printf %s\\n "${file#$ENVY_HOME/}"
        done
        ;;
      esac
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
# nv name is guaranteed not to contain spaces, tabs or newlines (IFS)
#
