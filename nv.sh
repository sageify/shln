nv() {
  case "$1" in
  '') nv grep "$(nv -p)" ;;
  -a)
    case "$2" in
    '')
      for __ in $(nv -pa); do
        nv grep "$__"
      done
      ;;
    domain) nv -ad ;;
    name) nv -an ;;
    pattern) nv -ap ;;
    close) nv close -a ;;
    esac
    ;;
  domain | -d) nv resolve -d "$envy_context" ;;
  -ad | -da)
    set | grep -E '^envy_domain_' | while IFS='=' read key _; do
      echo ${key#envy_domain_}
    done
    ;;
  name | -n)
    if [ -n "${2+x}" ]; then
      __=$(nv resolve -- "$2") && envy_context=$__ && echo $__
    else
      nv resolve -- "$envy_context"
    fi
    ;;
  -an | -na)
    for __ in $(nv -ad); do
      nv domains -n $__
    done
    ;;
  pattern | -p)
    if [ -n "${2+x}" ]; then
      envy_pattern="$2"
    else
      [ "$envy_pattern" ] && printf %s\\n "$envy_pattern"
    fi
    ;;
  -pa | -ap)
    for __ in $(nv -ad); do
      nv domains -p $__
    done
    ;;
  close)
    case "$2" in
    '') nv close -- "$(nv -d)" ;;
    -a)
      nv close -p
      for __ in $(nv -ad); do
        nv domains -c $__
      done
      ;;
    -p)
      nv unset -p
      unset envy_pattern
      ;;
    *)
      [ "$2" = -- ] && shift

      ! nv unset -d "$2" && return 1

      if [ "$(nv -d)" = "$2" ]; then
        nv unset -p
        nv switch nv
      fi

      unset envy_domain_$2
      ;;
    esac
    ;;

  domains)
    case "$2" in
    -e | exists) [ "$3" ] && __="$(eval 'echo $envy_domain_'$(nv resolve -d "$3"))" && [ "$__" ] ;;
    -v | value)
      [ "$3" ] && __="$(eval 'echo $envy_domain_'$(nv resolve -d "$3"))" &&
        [ "$__" ] && echo "$__"
      ;;
    -n | name) __="$(nv domains -v "$3")" && echo "${__%=${__#*=}}" ;;
    -p | pattern) __="$(nv domains -v "$3")" && echo "${__#*=}" ;;
    -c | close) nv unset -d "$3" && unset envy_domain_$3 ;;
    -h | help)
      cat <<EOF
usage: domain [ -e -v | -c | -p | -u | -h ] DOMAIN

Options
exist (-e)     check if domain exists
name (-n)      show the name
pattern (-p)   show the pattern
help (-h)      how this help
value (-v)     show value of the domain environment variable
close (-c)     unset domain and all domain environment variables
EOF
      ;;
    *) nv domains -v "$2" ;;
    esac
    ;;
  grep) [ "$2" ] && env | grep -E "$2" ;;
  resolve)
    case "$2" in
    -c | --check)
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
    -d | --domain)
      nv resolve -c "$3" && case "$3" in
      */*) echo ${3%/*} ;;
      '') echo nv ;;
      *) echo $3 ;;
      esac
      ;;
    *)
      [ "$2" = -- ] || [ "$2" = -n ] || [ "$2" = --name ] && shift
      nv resolve -c "$2" && case "$2" in
      */*) echo $2 ;;
      '') echo $(nv resolve -d)/default ;;
      *) echo $(nv resolve -d)/$2 ;;
      esac
      ;;
    esac
    ;;
  new)
    nv unset -p
    nv -p "${2-$(nv domains -p $(nv -d))}"
    nv unset -p
    ;;
  switch)
    ! nv domains -e "$2" && return 1
    nv -n "$(nv domains -n "$2")"
    nv -p "$(nv domains -p "$2")"
    ;;
  unset)
    case "$2" in
    -p | pattern)
      while IFS='=' read __ _; do
        [ "$__" ] && unset "$__"
      done <<EOF
$(nv grep "${3-$(nv -p)}")
EOF
      return 0
      ;;
    -d | domain) __="$(nv domains -p "${3-$(nv -d)}")" && nv unset -p "$__" ;;
    -h | help) echo "usage: unset [ -p [PATTERN] ] [ -d [DOMAIN] ] | NAME ..." ;;
    '') ;;
    *)
      [ "$2" = -v ] || [ "$2" = -- ] && shift
      shift
      for __ in "$@"; do
        if ! [ "$(printf %s "$__" | grep -E "$(nv -p)")" ]; then
          echo "unset: '$__': could not grep to: '$(nv -p)'" 1>&2
        else
          unset "$__"
        fi
      done
      ;;
    esac
    ;;
  uninstall)
    nv close -a
    unset -v ENVY_HOME
    # dangling local environment variables
    unset -v _ __ _nv_dv _nv_key _nv_line _nv_value
    unset -f nv
    ;;
  version) echo "envy version 0.1.1" ;;
  help | -h | --help)
    cat <<EOF
usage:  nv [-a] | [COMMAND]

Shows the current envionronment variables.

Option
-a  show all environment variables, domains, names or patterns

Current Environment
-n | name     show/set environment name
-p | pattern  show/set environment pattern
-d | domain   show environment domain

File
 new    create a new environment
 open   open a new environment
 save   save or replace the environment
 reset  reset environment to default

Environment
 domains   show specific domain inforation
 grep      grep all environment to an extended pattern
 switch    switch to enivronment of another domain
 unset     unset environment variables
 
Directory Management
 cat     show saved environment
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
 resolve     resolve a name or domain
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
      ! [ "$1" ] && set -- $(nv -n)

      for __ in "$@"; do
        ! nv -n "$__" && return 1
        nv -p ""
        nv unset -d $(nv -d)

        __=x
        while read _nv_line; do
          if [ $__ ]; then
            nv -p "$_nv_line"
            unset __
            continue
          fi

          IFS='=' read _nv_key _nv_value <<EOF
$_nv_line
EOF
          case "$_nv_key" in
          ENVY_HOME | ^envy_domain* | envy_context | '') ;;
          *)
            export $_nv_key="$_nv_value"
            ;;
          esac
        done <"$ENVY_HOME/$(nv -n)"

        # after nv -p set above
        eval 'envy_domain_'$(nv -d)'="$(nv -n)=$(nv -p)"'
      done
      ;;
    save)
      if [ "$2" ]; then
        ! nv -n "$2" && return 1
      else
        nv -n
      fi

      eval 'envy_domain_'$(nv -d)'="$(nv -n)=$(nv -p)"'

      mkdir -p "$ENVY_HOME/$(nv -d)"
      printf %s\\n "$(nv -p)" >"$ENVY_HOME/$(nv -n)"
      nv grep "$(nv -p)" >>"$ENVY_HOME/$(nv -n)"
      ;;
    reset)
      nv close -a
      while read __; do
        [ "$__" ] && nv open "$__"
      done <<EOF
$(nv find -a '/default')
EOF
      ;;
    cat) cat "$ENVY_HOME/$(nv resolve -- "${2-$(nv -n)}")" ;;
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
      '') nv find "*" ;;
      -d)
        find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$3" | while read file; do
          printf %s\\n "${file#$ENVY_HOME/}"
        done
        ;;
      -a)
        find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "*$3" | while read file; do
          printf %s\\n "${file#$ENVY_HOME/}"
        done
        ;;
      *)
        [ "$2" = -- ] && shift
        find "$ENVY_HOME/$(nv -d)" -mindepth 1 -maxdepth 1 -type f -name "$2" | while read file; do
          printf %s\\n "${file#$ENVY_HOME/$(nv -d)/}"
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
# nv -n and nv -d is guaranteed not to contain spaces, tabs or newlines (IFS)
#
