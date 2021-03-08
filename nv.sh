nv() {
  ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"

  case "$1" in
  '') nv -g "$(nv -p)" ;;
  all | -a)
    for __ in $(nv -pa); do
      nv -g "$__"
    done
    ;;

  cat) cat "$ENVY_HOME/$(nv -r "${2-$(nv -n)}")" ;;

  cd) cd "$ENVY_HOME/$(nv -d)" ;;

  close | -c | -ec | -ce)
    case "$2" in
    '') nv -c "$(nv -d)" ;;
    *)
      ! nv -du "$2" && return 1

      if [ "$(nv -d)" = "$2" ]; then
        nv -pu
        nv -d nv
      fi

      unset envy_domain_$2
      ;;
    esac
    ;;
  -ca | -ac)
    nv -pc
    for __ in $(nv -da); do
      nv -dc $__
    done
    unset -v envy_context
    ;;

  domain | -d)
    if [ "$2" ]; then
      ! nv -ev "$2" 1>/dev/null && return 1
      nv -n "$(nv -en "$2")"
      nv -p "$(nv -ep "$2")"
    else
      nv -rd "$envy_context"
    fi
    ;;
  -da | -ad)
    set | grep '^envy_domain_' | while IFS='=' read key _; do
      echo ${key#envy_domain_}
    done
    ;;
  -du | -ud) __="$(nv -ep "${2-$(nv -d)}")" && nv -pu "$__" ;;
  -df | -fd)
    find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/}"
    done
    ;;
  -dc | -cd) nv -du "$2" && unset envy_domain_$2 ;;

  env | -e | -ev | -ve) [ "$2" ] && __="$(eval 'echo $envy_domain_'$(nv -rd "$2"))" &&
    [ "$__" ] && echo "$__" ;;
  -en | -ne) __="$(nv -ev "$2")" && echo "${__%=${__#*=}}" ;;
  -ep | -pe) __="$(nv -ev "$2")" && echo "${__#*=}" ;;

  grep | -g) [ "$2" ] && env | grep -Ee "$2" ;;

  name | -n)
    if [ -n "${2+x}" ]; then
      __=$(nv -r "$2") && envy_context=$__ && echo $__
    else
      nv -r "$envy_context"
    fi
    ;;
  -na | -an)
    for __ in $(nv -da); do
      nv -en $__
    done
    ;;
  --find | -f | -nf | -fn)
    find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "*$2" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/}"
    done
    ;;
  -ff)
    find "$ENVY_HOME/$(nv -d)" -mindepth 1 -maxdepth 1 -type f -name "$2" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/$(nv -d)/}"
    done
    ;;

  new)
    nv -pu
    nv -p "${2-$(nv -ep $(nv -d))}"
    nv -pu
    ;;

  open | -o)
    shift
    ! [ "$1" ] && set -- $(nv -n)

    for __ in "$@"; do
      ! nv -n "$__" && return 1
      nv -p ""
      nv -du $(nv -d)

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

  pattern | -p)
    if [ -n "${2+x}" ]; then
      envy_pattern="$2"
    else
      [ "$envy_pattern" ] && printf %s\\n "$envy_pattern"
    fi
    ;;
  -pa | -ap)
    for __ in $(nv -da); do
      nv -ep $__
    done
    ;;
  -pu | -up)
    while IFS='=' read __ _; do
      [ "$__" ] && unset "$__"
    done <<EOF
$(nv -g "${2-$(nv -p)}")
EOF
    return 0
    ;;
  -pc | -cp) nv -pu && unset envy_pattern ;;

  reload)
    nv -ca
    while read __; do
      [ "$__" ] && nv -o "$__"
    done <<EOF
$(nv -f '/default')
EOF
    ;;

  resolve | -r | -rn | nr)
    nv -t "$2" && case "$2" in
    */*) echo $2 ;;
    '') echo $(nv -rd)/default ;;
    *) echo $(nv -rd)/$2 ;;
    esac
    ;;
  # resolve test
  -t)
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
  # domain resolve
  -rd | -dr)
    nv -t "$2" && case "$2" in
    */*) echo ${2%/*} ;;
    '') echo nv ;;
    *) echo $2 ;;
    esac
    ;;

  save | -s)
    if [ "$2" ]; then
      ! nv -n "$2" && return 1
    else
      nv -n
    fi

    eval 'envy_domain_'$(nv -d)'="$(nv -n)=$(nv -p)"'

    mkdir -p "$ENVY_HOME/$(nv -d)"
    printf %s\\n "$(nv -p)" >"$ENVY_HOME/$(nv -n)"
    nv -g "$(nv -p)" >>"$ENVY_HOME/$(nv -n)"
    ;;

  unset | -u)
    shift
    for __ in "$@"; do
      if ! [ "$(printf %s "$__" | grep -e "$(nv -p)")" ]; then
        echo "unset: '$__': could not grep to: '$(nv -p)'" 1>&2
      else
        unset "$__"
      fi
    done
    ;;

  uninstall)
    nv -ca
    unset -v ENVY_HOME
    # dangling local environment variables
    unset -v _ __ _nv_dv _nv_key _nv_line _nv_value
    unset -f nv
    ;;

  version) echo "envy version 0.3.0" ;;

  which | -w)
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

  help | -h | --help)
    cat <<EOF
usage:  nv [OPTIONS] [ [ RESOUCE ] | [ COMMAND ] ]

Shows and manages the domain environment variables.

Options
-a  show all
-c  close
-d  domain
-e  environment
-f  find
-h  help
-n  name
-p  pattern
-u  unset

Resource
-d, domain    show/set domain
-n, name      show/set environment name
-p, pattern   show/set environment pattern

Environment Commands
-a, all     show all domain environment variables
-e, env     show an active environment
-g, grep    grep all system environment variables
-u, unset   unset domain environment variable

Environment File
    cat     show an environment file
    cd      change to current environment directory
-c, close   close environment
-f, find    find files
    new     create a new environment
-o, open    open a new environment
-s, save    save or replace the environment
    reload  reset environment to default files
-w, which   show full file path to saved environment

General Commands
 -h, help        show this help
 -r, resolve     resolve a name
 -t              test a name component
     uninstall   unset everything and uninstall nv
     version     show version
EOF
    ;;
  *)
    echo "nv: $1: Unknown option" 1>&2
    nv -h 1>&2
    return 1
    ;;
  esac
}

mkdir -p "${ENVY_HOME-$HOME/.config/envy}"

if [ "$1" ]; then
  nv "$@"
fi
