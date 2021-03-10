nv() {
  ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"
  ENVY_EXCLUDE="${ENVY_EXCLUDE-^HOSTNAME=|^HOME=|^LC_|^PATH=|^PWD=|^SHELL=|^SHLVL=|^TERM=|^TERM_|^USER|^_=|^__}"

  case "$1" in
  
  '') nv -g- "$(nv -p-)" ;;

  all | -a | .)
    shift && case "$1" in
    -*) __="${1#-}" && shift && nv "-a$__" "$@" ;;
    *) nv -a- "$@" ;;
    esac
    ;;
  -a-)
    nv _e "$2" "all" && for __ in $(nv -pa); do
      nv -g- "$__"
    done
    ;;
  -ah | ha) echo "usage: all -dehnp" && return 0 ;;

  cat) cat "$ENVY_HOME/$(nv -nr "${2-$(nv -n-)}")" ;;

  cd | -x | -x-)
    ! nv -et "$2" && return 1
    nv -n- "$(nv -en "$2")"
    nv -p- "$(nv -ep "$2")"
    ;;

  close | -c)
    shift && case "$1" in
    '') nv -c- $(nv -d-) ;;
    -*) __="${1#-}" && shift && nv "-c$__" "$@" ;;
    *) nv -c- "$@" ;;
    esac
    ;;
  -c-) nv -ec "$2" && nv -n- "" ;;
  -ca | -ac | reset)
    nv -pc
    for __ in $(nv -da); do
      nv -ec $__
    done
    unset -v envy_name
    ;;
  -ch | -hc) echo "usage: close -aehp" && return 0 ;;

  domain | -d)
    shift && case "$1" in
    -*) __="${1#-}" && shift && nv "-d$__" "$@" ;;
    --) shift && nv -d- "$@" ;;
    *) nv -d- "$@" ;;
    esac
    ;;
  -d-) nv _e "$2" "domain" && nv -rd "$envy_name" ;;
  -da | -ad)
    nv _e "$2" "domain -a" && set | grep -e '^envy_env_' | while IFS='=' read key _; do
      echo ${key#envy_env_}
    done
    ;;
  -df | -fd)
    nv _e "$3" "domain -f $2" &&
      find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
    ;;
  -dr | -rd)
    nv -nt "$2" && case "$2" in
    */*) echo ${2%/*} ;;
    '') if [ $(nv -n-) ]; then nv -rd $(nv -n-); else 'nv'; fi ;;
    *) echo $2 ;;
    esac
    ;;
  -du | -ud) nv _e "$2" "domain -u" && nv -eu $(nv -d-) ;;
  -dh | hd) echo "usage: domain -acdhu" && return 0 ;;

  env | -e)
    shift && case "$1" in
    '') nv -e- $(nv -d-) ;;
    -*) __="${1#-}" && shift && nv "-e$__" "$@" ;;
    --) shift && nv -e- "$@" ;;
    *) nv -e- "$@" ;;
    esac
    ;;
  -e-) [ "$2" ] && __="$(eval 'echo $envy_env_'$(nv -rd "$2"))" &&
    [ "$__" ] && echo "$__" ;;
  -ea | -ae)
    nv _e "$2" "env -a" && for __ in $(nv -da); do
      echo $(nv -e- $__)
    done
    ;;
  -ec | -ce) nv -eu "$2" && unset envy_env_$2 ;;
  -en | -ne) __="$(nv -e- "$2")" && echo "${__%=${__#*=}}" ;;
  -ep | -pe) __="$(nv -e- "$2")" && echo "${__#*=}" ;;
  -et | -te) nv -e- "$2" 1>/dev/null ;;
  -eu | -ue) __="$(nv -ep "$2")" && nv -gu "$__" ;;
  -eh | he) echo "usage: env -acnptu" && return 0 ;;

  grep | -g)
    shift && case "$1" in
    *) nv -g- "$@" ;;
    -u) nv -gu "$@" ;;
    esac
    ;;
  -g-)
    if [ "$3" = '-' ]; then
      grep -vE -e "$ENVY_EXCLUDE" | grep -v -e "^ENVY_HOME|^ENVY_EXCLUDE|^envy_name|^envy_env*" |
        grep -E -e "$2" | sort
    else
      [ "$2" ] && env | nv -g- "$2" -
    fi
    ;;
  -gu | -ug)
    while IFS='=' read __ _; do
      [ "$__" ] && unset "$__"
    done <<EOF
$(nv -g- "$2")
EOF
    return 0
    ;;

  isnew)
    case "$(nv -n-)" in */) return 0 ;; esac
    return 1
    ;;

  name | -n | pwd)
    shift && case "$1" in
    -*) __="${1#-}" && shift && nv "-n$__" "$@" ;;
    --) shift && nv -n- "$@" ;;
    *) nv -n- "$@" ;;
    esac
    ;;
  -n-)
    if [ "${2+x}" ]; then
      __=$(nv -nr "$2") && envy_name=$__ && echo $__
    else
      nv -nr "$envy_name"
    fi
    ;;
  ls | -na | -an)
    for __ in $(nv -da); do
      nv -en $__
    done
    ;;
  find | -fn | -nf)
    find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/${2-*}" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/}"
    done
    ;;
  -ff)
    find "$ENVY_HOME/$(nv -d-)" -mindepth 1 -maxdepth 1 -type f -name "${2-*}" | while read file; do
      printf %s\\n "${file#$ENVY_HOME/$(nv -d-)/}"
    done
    ;;
  -nr | -rn)
    nv -nt "$2" && case "$2" in
    */*) echo $2 ;;
    *) echo $(nv -rd)/$2 ;;
    esac
    ;;
  -nt | -tn)
    case "$2" in
    /*)
      echo "name: $2: May not have a leading slash" 1>&2
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
  -nh) echo "usage: name -afhrt" && return 0 ;;

  new)
    nv -p- "${2-$(nv -p-)}"
    nv -n- ""
    ;;

  open | -o)
    shift
    ! [ "$1" ] && set -- $(nv -n-)

    for __ in "$@"; do
      ! nv -n- "$__" && return 1
      nv isnew && continue

      nv -du

      __=x
      while read _nv_line || [ "$_nv_line" ]; do
        if [ $__ ]; then
          nv -p- "$_nv_line"
          eval 'envy_env_'$(nv -d-)'="$(nv -n-)=$(nv -p-)"'
          unset __
          continue
        fi

        IFS='=' read _nv_key _nv_value <<EOF
$_nv_line
EOF
        printf %s "$_nv_key" | nv -g- . - >/dev/null && export "$_nv_key=$_nv_value"
      done <"$ENVY_HOME/$(nv -n-)"
    done
    ;;

  pattern | -p | --)
    shift && case "$1" in
    -*) __="${1#-}" && shift && nv "-p$__" "$@" ;;
    *) nv -p- "$@" && [ "$1" ] && ! nv && echo "nv: $1: No environment variables found" 1>&2 ;;
    esac
    ;;
  -p-)
    if [ -n "${2+x}" ]; then
      envy_pattern="$2"
    else
      printf %s\\n "${envy_pattern-.}"
    fi
    ;;
  -pa | -ap)
    nv _e "$2" "pattern -a" &&
      for __ in $(nv -da); do
        nv -ep $__
      done
    ;;
  -pu | -up) nv _e "$2" "pattern -u" && nv -gu "$(nv -p-)" ;;
  -pc | -cp) nv _e "$2" "pattern -c" && nv -pu && unset envy_pattern ;;
  -ph | -hp) echo "usage: name -achu" && exit 0 ;;

  reload)
    nv -ca
    while read __; do
      [ "$__" ] && nv -o "$__"
    done <<EOF
$(nv -fn '*/default')
EOF
    ;;

  resolve | -r)
    shift && case "$1" in
    -*) __="${1#-}" && shift && nv "-r$__" "$@" ;;
    --) shift && nv -rn "$@" ;;
    *) nv -rn "$@" ;;
    esac
    ;;
  -rh | -hr) echo "usage: resolve -ndh" && exit 0 ;;

  save | -s)
    if [ "$2" ]; then
      ! nv -n- "$2" && return 1
    else
      nv -n-
    fi

    nv isnew && echo "save: Must specify a name for a new environment" 1>&2 && return 1

    eval 'envy_env_'$(nv -d-)'="$(nv -n-)=$(nv -p-)"'

    mkdir -p "$ENVY_HOME/$(nv -d-)"
    printf %s\\n "$(nv -p-)" >"$ENVY_HOME/$(nv -n-)"
    nv -g- "$(nv -p-)" >>"$ENVY_HOME/$(nv -n-)"
    ;;

  set)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv -g- "$(nv -p-)" - >/dev/null; then
        echo "unset: '$__': Not applicable to current environment" 1>&2
      else
        export "$__"
      fi
    done
    ;;

  unset)
    shift && case "$1" in
    *) nv -u- "$@" ;;
    esac
    ;;
  -u-)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv -g- "$(nv -p-)" - >/dev/null; then
        echo "unset: '$__': Not applicable to current environment" 1>&2
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
-r  resolve
-u  unset

Resource
-d, domain    print current environment domain name
-n, name      print/set current environment full name
-p, pattern   print/set current environment pattern
-e, env       print current environment or a specified environment

Environment Commands
-a, all, .    show all managed environment variables
    cd        change to an environment
-c, close     close environment
    ls, -na   print active environment names
    new       create a new environment
-n, pwd       print name of current environment
-u, unset     unset a current environment variable

Environment File
    cat     show an environment file
-f, find    find all environment files
-o, open    open a new environment from file
-s, save    save or replace the environment
    reload  reset environment to default files
-w, which   show full file path to saved environment

General Commands
 -g, grep        grep all system environment variables
 -h, help        show this help
     isnew       check if new environment
 -t              test a name component
     resolve     resolve a name
     uninstall   unset everything and uninstall nv
     version     show version
EOF
    ;;

  # internal - empty argument
  _e)
    ! [ "$2" ] && return 0
    echo "$3 $2: Too many arguments" 1>&2
    return 1
    ;;

  -*) echo "nv: $1: Unknown option" 1>&2 && nv -h 1>&2 && return 1 ;;
  *) echo "nv: $1: Unknown resource or command" 1>&2 && nv -h 1>&2 && return 1 ;;
  esac
}

mkdir -p "${ENVY_HOME-$HOME/.config/envy}"

if [ "$1" ]; then
  nv "$@"
fi
