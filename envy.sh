# shellcheck shell=sh
nv() {
  case $1 in
  '') nv g- "$(nv p-)" ;;

  all | a | .) nv g- "." ;;

  cat) cat -- "$ENVY_HOME/$(nv rn "${2-$(nv n-)}")" ;;

  cd)
    ! nv et "$2" && return 1
    nv n- "$(nv en "$2")"
    nv p- "$(nv ep "$2")"
    ;;

  close | c)
    shift && case $1 in
    '') nv c- "$(nv d-)" ;;
    --) nv c- "$@" ;;
    -*) __="${1#-}" && shift && nv "c$__" "$@" ;;
    *) nv c- "$@" ;;
    esac
    ;;
  c-) nv ec "$2" && nv n- "" ;;
  reset | ca | ac)
    nv pc
    for __ in $(nv da); do
      nv ec "$__"
    done
    unset -v envy_name
    ;;
  ch | hc) echo "usage: close -aehp" ;;

  domain | d)
    shift && case $1 in
    -*) __="${1#-}" && shift && nv "d$__" "$@" ;;
    *) nv d- "$@" ;;
    esac
    ;;
  d-) nv _e "$2" "domain" && nv rd "$envy_name" ;;
  da | ad)
    nv _e "$2" "domain -a" && set | grep -e '^envy_env_' | while IFS='=' read -r key _; do
      printf %s\\n "${key#envy_env_}"
    done
    ;;
  df | fd)
    nv _e "$3" "domain -f $2" &&
      find "$ENVY_HOME" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
    ;;
  du | ud) nv _e "$2" "domain -u" && nv eu "$(nv d-)" ;;
  dh | hd) echo "usage: domain -acdhu" ;;

  edit)
    shift
    # ! command -v -- "$GRM_EDITOR" >/dev/null &&
    #   echo "edit: Editor '$GRM_EDITOR' not found" 1>&2 &&
    #   return 1
    if [ "$1" ]; then
      code "$(nv w- "$(nv rn "$1")")"
    else
      code "$(nv home)"
    fi
    ;;

  env | e)
    shift && case $1 in
    '') nv ea ;;
    --) shift && nv e- "$@" ;;
    -*) __="${1#-}" && shift && nv "e$__" "$@" ;;
    *) nv e- "$@" ;;
    esac
    ;;
  e-) [ "$2" ] && __="$(eval 'echo $envy_env_'"$(nv rd "$2")")" &&
    [ "$__" ] && echo "$__" ;;
  ea | ae)
    nv _e "$2" "env -a" && for __ in $(nv da); do
      printf %s\\n "$(nv e- "$__")"
    done
    ;;
  ec | ce) nv eu "$2" && unset envy_env_"$2" ;;
  en | ne) __="$(nv e- "$2")" && printf %s\\n "${__%% *}" ;;
  ep | pe) __="$(nv e- "$2")" && printf %s\\n "${__#* }" ;;
  et | te) nv e- "$2" 1>/dev/null ;;
  eu | ue) __="$(nv ep "$2")" && nv gu "$__" ;;
  eh | he) echo "usage: env -acnptu" ;;

  exclude) printf %s\\n "$ENVY_EXCLUDE" ;;

  find | f)
    shift && case $1 in
    -*) __="${1#-}" && shift && nv "f$__" "$@" ;;
    *) nv f- "$@" ;;
    esac
    ;;
  f-)
    find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/$(nv d-)/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
    ;;
  find-all | fa)
    find "$ENVY_HOME" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/}"
      done
    ;;

  grep | g)
    shift && case $1 in
    -u) nv gu "$@" ;;
    *) nv g- "$@" ;;
    esac
    ;;
  g-)
    if [ "$3" = '-' ]; then
      # '-' for stdin. last grep is to get return 1 on empty
      grep -vE -e "$ENVY_EXCLUDE" | grep -v -e "^ENVY_HOME|^ENVY_EXCLUDE|^envy_name|^envy_env*" |
        grep -E -e "$2" | sort | grep -e '.'
    else
      [ "$2" ] && env | nv g- "$2" -
    fi
    ;;
  gu | ug)
    while IFS='=' read -r __ _; do
      [ "$__" ] && unset "$__"
    done <<EOF
$(nv g- "$2")
EOF
    return 0
    ;;

  home) printf %s\\n "$ENVY_HOME" ;;

  isnew) case $(nv n-) in */) ;; *) return 1 ;; esac ;;

  name | n | pwd)
    shift && case $1 in
    --) shift && nv n- "$@" ;;
    -*) __="${1#-}" && shift && nv "n$__" "$@" ;;
    *) nv n- "$@" ;;
    esac
    ;;
  n-)
    if [ "${2+x}" ]; then
      __=$(nv rn "$2") && envy_name=$__ && echo "$__"
    else
      nv rn "$envy_name"
    fi
    ;;
  ls | na | an)
    for __ in $(nv da); do
      nv en "$__"
    done
    ;;
  nh | hn) echo "usage: name -afhrt" ;;

  new)
    nv n- "$2"
    nv p- "${3-$(nv p-)}"
    ;;

  open | o)
    shift
    ! [ "$1" ] && set -- "$(nv n-)"

    for __ in "$@"; do
      ! nv n- "$__" && return 1
      nv isnew && continue

      # unset new domain set above
      nv du

      while read -r _nv_line || [ "$_nv_line" ]; do
        case $_nv_line in
        \#*) continue ;;
        +*)
          nv p- "${_nv_line#*+}"
          eval 'envy_env_'"$(nv d-)"'="$(nv n-) $(nv p-)"'
          unset __
          continue
          ;;
        *=*)
          # pass through grep of pattern to exluce any excluded envirnment variables
          printf %s "${_nv_line%%=*}" | nv g- . - >/dev/null &&
            export "${_nv_line%%=*}=${_nv_line#*=}"
          ;;
        *) [ "$_nv_line" ] && echo "open: $_nv_line: Warning. Line ignored" 1>&2 ;;
        esac
      done <"$ENVY_HOME/$(nv n-)"
    done
    ;;

  pattern | p)
    shift && case $1 in
    -*) __="${1#-}" && shift && nv "p$__" "$@" ;;
    *) nv p- "$@" && [ "$1" ] && ! nv && echo "nv: $1: No environment variables found" 1>&2 ;;
    esac
    ;;
  p-)
    if [ -n "${2+x}" ]; then
      envy_pattern="$2"
    else
      printf %s\\n "${envy_pattern-.}"
    fi
    ;;
  pattern-all | pa | ap)
    nv _e "$2" "pattern-all" &&
      for __ in $(nv da); do
        nv ep "$__"
      done
    ;;
  pu | up) nv _e "$2" "pattern -u" && nv gu "$(nv p-)" ;;
  pc | cp) nv _e "$2" "pattern -c" && nv pu && unset envy_pattern ;;
  ph | hp) echo "usage: name -achu" ;;

  resolve)
    shift && case $1 in
    --) shift && nv rn "$@" ;;
    -*) __="${1#-}" && shift && nv "r$__" "$@" ;;
    *) nv rn "$@" ;;
    esac
    ;;
  rt)
    # resolve test name
    case $2 in
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
  rd)
    nv rt "$2" && case $2 in
    */*) echo "${2%/*}" ;;
    '') if [ "$envy_name" ]; then nv rd "$envy_name"; else echo 'nv'; fi ;;
    *) echo "$2" ;;
    esac
    ;;
  rn)
    nv rt "$2" && case $2 in
    */*) echo "$2" ;;
    *) echo "$(nv rd)/$2" ;;
    esac
    ;;
  rh | hr) echo "usage: resolve -dnth" ;;

  save | s)
    if [ "$2" ]; then
      ! nv n- "$2" && return 1
    else
      nv n-
    fi

    nv isnew && echo "save: Must provide a new environment name" 1>&2 && return 1

    eval 'envy_env_'"$(nv d-)"'="$(nv n-) $(nv p-)"'

    mkdir -p -- "$ENVY_HOME/$(nv d-)"
    printf %s\\n "+$(nv p-)" >"$ENVY_HOME/$(nv n-)"
    nv g- "$(nv p-)" >>"$ENVY_HOME/$(nv n-)"
    ;;

  set)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv g- "$(nv p-)" - >/dev/null; then
        echo "set: '$__': Not applicable to current environment" 1>&2
      else
        # shellcheck disable=SC2163
        export "$__"
      fi
    done
    ;;

  unset | u)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv g- "$(nv p-)" - >/dev/null; then
        echo "unset: '$__': Not applicable to current environment" 1>&2
      else
        unset "$__"
      fi
    done
    ;;

  uninstall)
    nv ca
    unset -v ENVY_HOME
    # dangling local environment variables
    unset -v _ __ _nv_dv _nv_key _nv_line _nv_value
    unset -f nv
    ;;

  version) echo "envy version 0.4.1" ;;

  which | w | w-)
    __="$ENVY_HOME/$2" && ! [ -f "$__" ] && ! [ -d "$__" ] &&
      echo "$2 not found" 1>&2 &&
      return 1
    printf %s\\n "$__"
    ;;

  help | -h | --help)
    cat <<EOF
usage:  nv [OPTIONS] [ [ RESOUCE ] | [ COMMAND ] ]

Shows and manages the domain environment variables.

Options
-a  show for all active environments
-f  find in saved environments
-h  help

Resource
d, domain    Print current environment domain name
n, name      Print/set current environment full name
p, pattern   Print/set current environment pattern
e, env       Print all opened environments or a specified environment

Environment Commands
., all       Show all managed environment variables
   cd        Change to an environment
c, close     Close environment
   ls, na    Print active environment names
   new       Create a new environment
n, pwd       Print name of current environment
u, unset     Unset a current environment variable

Environment File
   cat     Print an environment file
f, find    Find all environment files
o, open    Open a new environment from file
s, save    Save or replace the environment
w, which   Print full file path to saved environment

Other Commands
    exclude     Print global environment exclude pattern
 g, grep        Grep global environment variables
    help        Show this help
    isnew       Check if new environment
    resolve     Resolve a name
    uninstall   Unset everything and uninstall nv function
    version     Print the version information
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

ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"
ENVY_EXCLUDE="${ENVY_EXCLUDE-^(COLOR|COMMAND_|ENVY_|HOSTNAME=|HOME=|LANG=|LaunchInstanceID=|LOGNAME=|ITERM_|LC_|OLDPWD=|PATH=|PWD=|SECURITYSESSIONID=|SHELL=|SHLVL=|SSH_|TERM=|TERM_|TMPDIR=|USER|XPC_|_=|__)}"

mkdir -p -- "$ENVY_HOME"

# shellcheck disable=SC2046
[ -f "$ENVY_HOME/.nvopen" ] && nv open $(cat -- "$ENVY_HOME/.nvopen")

#
# must install nv: . nv
#
