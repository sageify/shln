nv() {
  ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"

  case "$1" in
  '') nv -g "$(nv -pp)" ;;

  all | -a)
    shift && case "$1" in
    -d) nv -da "$@" ;;
    -e) nv -de "$@" ;;
    -h) echo "usage: all -dehnp" && return 0 ;;
    -n) nv -na "$@" ;;
    -p) nv -pa "$@" ;;
    -*) echo "all: $1: Unknown option" 1>&2 && nv all -h 1>&2 && return 1 ;;
    *) nv -aa "$@" ;;
    esac
    ;;
  -aa)
    nv _nea "$2" "all" && for __ in $(nv -pa); do
      nv -g "$__"
    done
    ;;

  cat) cat "$ENVY_HOME/$(nv -r "${2-$(nv -nn)}")" ;;

  cd) cd "$ENVY_HOME/$(nv -dd)" ;;

  close | -c)
    shift && case "$1" in
    -a) shift && -ca "$@" ;;
    '') nv close $(nv -dd) ;;
    *) nv -ec "$@" && nv -ee nv ;;
    esac
    ;;
  -ca | -ac)
    nv -pc
    for __ in $(nv -da); do
      nv -ec $__
    done
    unset -v envy_name
    ;;

  # internal - no extra arguments
  _nea)
    ! [ "$2" ] && return 0
    echo "$3 $2: Too many arguments" 1>&2
    return 1
    ;;

  domain | -d)
    shift && case "$1" in
    -a) shift && nv -da "$@" ;;
    -c) shift && nv -dc "$@" ;;
    -f) shift && nv -df "$@" ;;
    -h) echo "usage: domain -acdhu" && return 0 ;;
    -u) shift && nv -du "$@" ;;
    -*) echo "domain: $1: Unknown option" 1>&2 && nv domain -h 1>&2 && return 1 ;;
    *) nv -dd "$@" ;;
    esac
    ;;
  -dd) nv _nea "$2" "domain" && nv -rd "$envy_name" ;;
  -da | -ad)
    nv _nea "$2" "domain -a" && set | grep '^envy_env_' | while IFS='=' read key _; do
      echo ${key#envy_env_}
    done
    ;;
  -dc | -cd) nv _nea "$2" "domain -c" && nv -ec $(nv -dd) ;;
  -df | -fd)
    nv _nea "$3" "domain -f $2" &&
      find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
    ;;
  -du | -ud) nv _nea "$2" "domain -u" && nv -eu $(nv -dd) ;;

  env | -e)
    shift && case "$1" in
    -a) shift && nv -ea "$@" ;;
    *) nv -ee "$@" ;;
    esac
    ;;
  -ee)
    ! nv -ev "$2" 1>/dev/null && return 1
    nv -nn "$(nv -en "$2")"
    nv -pp "$(nv -ep "$2")"
    ;;
  -ea | -ae)
    nv _nea "$2" "env -a" && for __ in $(nv -da); do
      echo $(nv -ev $__)
    done
    ;;
  -ec | -ce) nv -eu "$2" && unset envy_env_$2 ;;
  -en | -ne) __="$(nv -ev "$2")" && echo "${__%=${__#*=}}" ;;
  -ep | -pe) __="$(nv -ev "$2")" && echo "${__#*=}" ;;
  -eu | -ue) __="$(nv -ep "$2")" && nv -pu "$__" ;;
  -ev | -ve) [ "$2" ] && __="$(eval 'echo $envy_env_'$(nv -rd "$2"))" &&
    [ "$__" ] && echo "$__" ;;

  grep | -g) [ "$2" ] && env | grep -Ee "$2" ;;

  name | -n)
    shift && case "$1" in
    '') nv -nn "$@" ;;
    -a) shift && nv -na "$@" ;;
    -f) shift && nv -nf "$@" ;;
    -h) echo "usage: name -afh" && exit 0 ;;
    esac
    ;;
  -nn)
    if [ -n "${2+x}" ]; then
      __=$(nv -r "$2") && envy_name=$__ && echo $__
    else
      nv -r "$envy_name"
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
    find "$ENVY_HOME/$(nv -dd)" -mindepth 1 -maxdepth 1 -type f -name "$2" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/$(nv -dd)/}"
    done
    ;;

  new)
    nv -pu
    nv -pp "${2-$(nv -ep $(nv -dd))}"
    nv -pu
    ;;

  open | -o)
    shift
    ! [ "$1" ] && set -- $(nv -nn)

    for __ in "$@"; do
      ! nv -nn "$__" && return 1
      nv -pp ""
      nv -du

      __=x
      while read _nv_line; do
        if [ $__ ]; then
          nv -pp "$_nv_line"
          eval 'envy_env_'$(nv -dd)'="$(nv -nn)=$(nv -pp)"'
          unset __
          continue
        fi

        IFS='=' read _nv_key _nv_value <<EOF
$_nv_line
EOF
        case "$_nv_key" in
        ENVY_HOME | ^envy_domain* | envy_name | '') ;;
        *)
          export $_nv_key="$_nv_value"
          ;;
        esac
      done <"$ENVY_HOME/$(nv -nn)"
    done
    ;;

  pattern | -p)
    shift && case "$1" in
    '') nv -pp "$@" ;;
    -a) shift && nv -pa "$@" ;;
    -c) shift && nv -pc "$@" ;;
    -h) echo "usage: name -achu" && exit 0 ;;
    -u) shift && nv -pu "$@" ;;
    esac
    ;;
  -pp)
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
$(nv -g "${2-$(nv -pp)}")
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
      ! nv -nn "$2" && return 1
    else
      nv -nn
    fi

    eval 'envy_env_'$(nv -dd)'="$(nv -nn)=$(nv -pp)"'

    mkdir -p "$ENVY_HOME/$(nv -dd)"
    printf %s\\n "$(nv -pp)" >"$ENVY_HOME/$(nv -nn)"
    nv -g "$(nv -pp)" >>"$ENVY_HOME/$(nv -nn)"
    ;;

  unset)
    shift && case "$1" in
    *) nv -xu "$@" ;;
    esac
    ;;
  -xu | ux)
    shift
    for __ in "$@"; do
      if ! [ "$(printf %s "$__" | grep -e "$(nv -pp)")" ]; then
        echo "unset: '$__': could not grep to: '$(nv -pp)'" 1>&2
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
