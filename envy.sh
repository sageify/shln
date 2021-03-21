# shellcheck shell=sh
nv() {
  case $1 in
  '') nv g-- "$(nv p--)" ;;

  close | c | domain | d | env | e | find | f | grep | g | name | n | pattern | p | resolve)
    # normal style command
    cmd=$1
    shift && case $1 in
    '')
      case $cmd in
      close | c) nv c-- "$(nv d--)" ;;
      env | e) nv ea ;;
      *) nv "$cmd--" ;;
      esac
      ;;
    -*) __="$1" && shift && nv "$cmd$__" "$@" ;;
    *) nv "$cmd--" "$@" ;;
    esac
    ;;

  close-- | c--) nv ec "$2" && nv n-- "" ;;
  reset | close-a | c-a | ca)
    nv pc
    for __ in $(nv da); do
      nv ec "$__"
    done
    unset -v envy_name
    ;;

  domain-- | d--) nv _e "$2" "domain" && nv rd "$envy_name" ;;
  domain-a | d-a | da)
    nv _e "$2" "domain -a" && set | grep -e '^envy_env_' | while IFS='=' read -r key _; do
      printf %s\\n "${key#envy_env_}"
    done
    ;;
  domain-f | d-f | df)
    nv _e "$3" "domain -f $2" &&
      find "$ENVY_HOME/env" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/env/}"
      done
    ;;
  domain-u | d-u | du) nv _e "$2" "domain -u" && nv eu "$(nv d--)" ;;
  domain-h | d-h | dh) echo "usage: domain -afu" ;;

  env-- | e--)
    [ "$2" ] && __="$(eval 'echo $envy_env_'"$(nv rd "$2")")" && [ "$__" ] &&
      echo "$__"
    ;;
  env-a | e-a | ea)
    nv _e "$2" "env -a" && for __ in $(nv da); do
      printf %s\\n "$(nv e-- "$__")"
    done
    ;;
  env-c | e-c | ec) nv eu "$2" && unset envy_env_"$2" ;;
  env-n | e-n | en)
    if [ "$2" ]; then
      __="$(nv e-- "$2")" && printf %s\\n "${__%% *}"
    else
      nv na
    fi
    ;;
  env-p | e-p | ep)
    __="$(nv e-- "$2")" && printf %s\\n "${__#* }"
    ;;
  env-t | e-t | et) nv e-- "$2" 1>/dev/null ;;
  env-u | e-u | eu) __="$(nv ep "$2")" && nv gu "$__" ;;

  find-- | f--)
    find "$ENVY_HOME/env" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/env/$(nv d--)/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/env/}"
      done
    ;;
  find-all | find-a | f-a | fa)
    find "$ENVY_HOME/env" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/env/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/env/}"
      done
    ;;

  grep-- | g--)
    if [ "$3" = '-' ]; then
      # '-' for stdin. last grep is to get return 1 on empty
      grep -vE -e "$ENVY_EXCLUDE" | grep -v -e "^ENVY_HOME|^ENVY_EXCLUDE|^envy_name|^envy_env*" |
        grep -E -e "$2" | sort | grep -e '.'
    else
      [ "$2" ] && env | nv g-- "$2" -
    fi
    ;;
  grep-u | gu | ug)
    while IFS='=' read -r __ _; do
      [ "$__" ] && unset "$__"
    done <<EOF
$(nv g-- "$2")
EOF
    return 0
    ;;

  name-- | n--)
    if [ "${2+x}" ]; then
      __=$(nv rn "$2") && envy_name=$__ && echo "$__"
    else
      nv rn "$envy_name"
    fi
    ;;
  name-a | n-a | ls | na)
    for __ in $(nv da); do
      nv en "$__"
    done
    ;;

  pattern-- | p--)
    if [ -n "${2+x}" ]; then
      envy_pattern="$2"
    else
      printf %s\\n "${envy_pattern-.}"
    fi
    ;;
  pattern-a | pa | ap)
    nv _e "$2" "pattern -a" &&
      for __ in $(nv da); do
        nv ep "$__"
      done
    ;;
  pattern-c | pc | cp) nv _e "$2" "pattern -c" && nv pu && unset envy_pattern ;;
  pattern-u | pu | up) nv _e "$2" "pattern -u" && nv gu "$(nv p--)" ;;

  resolve-- | rn)
    nv rt "$2" && case $2 in
    */*) echo "$2" ;;
    *) echo "$(nv rd)/$2" ;;
    esac
    ;;
  resolve-t | rt)
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
  resolve-d | rd)
    nv rt "$2" && case $2 in
    */*) echo "${2%/*}" ;;
    '') if [ "$envy_name" ]; then nv rd "$envy_name"; else echo 'nv'; fi ;;
    *) echo "$2" ;;
    esac
    ;;

  #
  # No options or flags
  #

  all | .) nv g-- "." ;;

  cat) cat -- "$ENVY_HOME/env/$(nv rn "${2-$(nv n--)}")" ;;

  cd)
    ! nv et "$2" && return 1
    nv n-- "$(nv en "$2")"
    nv p-- "$(nv ep "$2")"
    ;;

  edit)
    shift
    # ! command -v -- "$GRM_EDITOR" >/dev/null &&
    #   echo "edit: Editor '$GRM_EDITOR' not found" 1>&2 &&
    #   return 1
    if [ "$1" ]; then
      code "$(nv w-- "$(nv rn "$1")")"
    else
      code "$(nv home)"
    fi
    ;;

  exclude) printf %s\\n "$ENVY_EXCLUDE" ;;

  home) printf %s\\n "$ENVY_HOME" ;;

  isnew) case $(nv n--) in */) ;; *) return 1 ;; esac ;;

  profile)
    shift && case $1 in
    '') nv profile-h 1>&2 && return 1 ;;
    *) __="$1" && shift && nv "profile-$__" "$@" ;;
    esac
    ;;
  profile-open | profile-open--)
    shift
    for __ in "$@"; do
      # shellcheck disable=SC2046
      nv open $(cat -- "$ENVY_HOME/profile/$__")
    done
    ;;
  profile-save | profile-save--)
    shift && ! [ "$1" ] && echo "nv: Expecting profile name" && return 1
    nv na >"$ENVY_HOME/profile/$1"
    ;;
  profile-find | profile-find--) ;;

  pwd) nv _e "$2" "pwd" && nv n-- ;;

  new)
    nv n-- "$2"
    nv p-- "${3-$(nv p--)}"
    ;;

  open | o | open-- | o--)
    shift
    ! [ "$1" ] && set -- "$(nv n--)"
    for __ in "$@"; do
      ! nv n-- "$__" && return 1
      nv isnew && continue

      # unset new domain set above
      nv du

      while read -r _nv_line || [ "$_nv_line" ]; do
        case $_nv_line in
        \#*) continue ;;
        +*)
          nv p-- "${_nv_line#*+}"
          eval 'envy_env_'"$(nv d--)"'="$(nv n--) $(nv p--)"'
          ;;
        *=*)
          # pass through grep of pattern to exlude any excluded envirnment variables
          printf %s "${_nv_line%%=*}" | nv g-- . - >/dev/null &&
            export "${_nv_line%%=*}=${_nv_line#*=}"
          ;;
        *) [ "$_nv_line" ] && echo "open: $_nv_line: Warning. Line ignored" 1>&2 ;;
        esac
      done <"$ENVY_HOME/env/$(nv n--)"
    done
    ;;

  save | s)
    if [ "$2" ]; then
      ! nv n-- "$2" && return 1
    else
      nv n--
    fi

    nv isnew && echo "save: Must provide a new environment name" 1>&2 && return 1

    eval 'envy_env_'"$(nv d--)"'="$(nv n--) $(nv p--)"'

    mkdir -p -- "$ENVY_HOME/env/$(nv d--)"
    printf %s\\n "+$(nv p--)" >"$ENVY_HOME/env/$(nv n--)"
    nv g-- "$(nv p--)" >>"$ENVY_HOME/env/$(nv n--)"
    ;;

  set | set--)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv g-- "$(nv p--)" - >/dev/null; then
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
      if ! printf %s "$__" | nv g-- "$(nv p--)" - >/dev/null; then
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

  version | --version) echo "envy version 0.5.0" ;;

  which | w | which-- | w--)
    __="$ENVY_HOME/env/$2" && ! [ -f "$__" ] && ! [ -d "$__" ] &&
      echo "$2 not found" 1>&2 &&
      return 1
    printf %s\\n "$__"
    ;;

  help | -h | --help)
    shift && case $1 in
    '') nv h-- ;;
    *) nv "help-$1" "$@" ;;
    esac
    ;;

  h--)
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
  help-close | help-c | close-h | c-h) echo "usage: close -aehp" ;;
  help-env | help-e | env-h | e-h) echo "usage: env -acnptu" ;;
  help-name | help-n | name-h | n-h) echo "usage: name -afh" ;;
  help-pattern | help-p | pattern-h | ph) echo "usage: name -achu" ;;
  help-resolve | help-r | resolve-h | r-h) echo "usage: resolve -dnth" ;;

  # internal - empty argument
  _e)
    ! [ "$2" ] && return 0
    echo "$3 $2: too many arguments" 1>&2
    return 1
    ;;

  -*) echo "nv: $1: Unknown option" 1>&2 && nv -h 1>&2 && return 1 ;;
  *) echo "nv: $1: Unknown resource or command" 1>&2 && nv -h 1>&2 && return 1 ;;
  esac
}

ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"
ENVY_EXCLUDE="${ENVY_EXCLUDE-^(COLOR|COMMAND_|ENVY_|HOSTNAME=|HOME=|LANG=|LaunchInstanceID=|LOGNAME=|ITERM_|LC_|OLDPWD=|PATH=|PWD=|SECURITYSESSIONID=|SHELL=|SHLVL=|SSH_|TERM=|TERM_|TMPDIR=|USER|XPC_|_=|__)}"
# any default (or override of above) environment variables may be set in .nvrc
[ -f "$ENVY_HOME/.nvrc" ] &&
  while read -r __; do
    # shellcheck disable=SC2163
    export "$__"
  done <"$ENVY_HOME/.nvrc"

[ -f "$ENVY_HOME/profile/nv" ] && nv profile open-- nv

mkdir -p -- "$ENVY_HOME/env"
mkdir -p -- "$ENVY_HOME/profile"

#
# must source: . nv
#
