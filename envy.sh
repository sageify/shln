# shellcheck shell=sh
nv() {
  case $1 in
  '') nv printenv ;;

  close | c | domain | d | env | e | find | f | grep | g | name | n | open | o | pattern | p | printenv | profile-open | profile-save | resolve | save | s)
    __nv_cmd=$1
    shift && case $1 in
    '')
      case $__nv_cmd in
      close | c) nv c-- "$(nv rd "$envy_name")" ;;
      domain | d) nv rd "$envy_name" ;;
      env | e) nv ea ;;
      name | n) nv rn "$envy_name" ;;
      open | o) nv o-- "$(nv rn "$envy_name")" ;;
      pattern | p) printf %s\\n "${envy_pattern-.}" ;;
      printenv) nv g-- "$(printf %s\\n "${envy_pattern-.}")" ;;
      profile-open) nv profile-open-- "$envy_profile" ;;
      profile-save) nv profile-save-- "$envy_profile" ;;
      save | s) nv s-- "$(nv rn "$envy_name")" ;;
      *) nv "$__nv_cmd--" ;;
      esac
      ;;
    -*) __="$1" && shift && nv "$__nv_cmd$__" "$@" ;;
    *) nv "$__nv_cmd--" "$@" ;;
    esac
    ;;

  close-- | c--) nv ec "$2" && nv n-- "" ;;
  reset | close-a | c-a | ca)
    for __ in $(nv da); do
      nv ec "$__"
    done
    unset -v envy_name
    unset -v envy_pattern
    ;;

  domain-a | d-a | da)
    nv _e "$2" "domain -a" && set | grep -e '^envy_env_' | while IFS='=' read -r key _; do
      printf %s\\n "${key#envy_env_}"
    done
    ;;
  domain-f | d-f | df)
    nv _e "$3" "domain -f $2" &&
      find "$envy_home/env" -mindepth 1 -maxdepth 1 -type d -path "*$2" | while read -r file; do
        printf %s\\n "${file#$envy_home/env/}"
      done
    ;;
  domain-u | d-u | du) nv _e "$2" "domain -u" && nv eu "$(nv d)" ;;
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
    find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/$(nv d)/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$envy_home/env/}"
      done
    ;;
  find-all | find-a | f-a | fa)
    find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/${2-*}" |
      while read -r file; do
        printf %s\\n "${file#$envy_home/env/}"
      done
    ;;

  grep-- | g--)
    if [ "$3" = '-' ]; then
      # '-' for stdin. last grep is to get return 1 on empty
      grep -vE -e "^($envy_exclude)" | grep -E -e "^($2)" | sort | grep -e '.'
    else
      [ "$2" ] && env | nv g-- "$2" -
    fi
    ;;
  grep-u | g-u | gu)
    while IFS='=' read -r __ _; do
      [ "$__" ] && unset "$__"
    done <<EOF
$(nv g-- "$2")
EOF
    return 0
    ;;

  name-- | n--) [ "${2+x}" ] && __=$(nv rn "$2") && envy_name=$__ && echo "$__" ;;
  name-a | n-a | ls | na)
    for __ in $(nv da); do
      nv en "$__"
    done
    ;;

  open-- | o--)
    shift && ! [ "$1" ] && return 1
    for __ in "$@"; do
      ! nv n-- "$__" && return 1
      nv isnew && continue

      # unset new domain set above
      nv du

      while read -r __nv_line || [ "$__nv_line" ]; do
        case $__nv_line in
        \#*) continue ;;
        +*)
          nv p-- "${__nv_line#*+}"
          eval 'envy_env_'"$(nv d)"'="$(nv n) $(nv p)"'
          ;;
        *=*)
          # pass through grep of pattern to exlude any excluded envirnment variables
          printf %s "$__nv_line" | nv g-- . - >/dev/null &&
            export "${__nv_line%%=*}=${__nv_line#*=}"
          ;;
        *) [ "$__nv_line" ] && echo "open: $__nv_line: Warning. Line ignored" 1>&2 ;;
        esac
      done <"$envy_home/env/$(nv n)"
    done
    ;;

  pattern-- | p--) [ -n "${2+x}" ] && envy_pattern="$2" ;;
  pattern-a | p-a | pa)
    nv _e "$2" "pattern -a" &&
      for __ in $(nv da); do
        nv ep "$__"
      done
    ;;
  pattern-c | p-c | pc) nv _e "$2" "pattern -c" && nv pu && unset envy_pattern ;;
  pattern-u | p-u | pu) nv _e "$2" "pattern -u" && nv gu "$(nv p)" ;;

  printenv--)
    shift
    for __ in "$@"; do
      __nv_line=$(nv g-- "$__=") && printf %s\\n "${__nv_line#*=}"
    done
    ;;

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
      echo "name: $2: May contain only alphanumeric or underscore" 1>&2
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

  save-- | s--)
    shift && ! [ "$1" ] && return 1
    ! nv n-- "$1" && return 1

    # if still new (name wasn't assigned above)
    nv isnew && echo "save: Must provide a new environment name" 1>&2 && return 1

    eval 'envy_env_'"$(nv d)"'="$(nv n) $(nv p)"'

    mkdir -p -- "$envy_home/env/$(nv d)"
    printf %s\\n "+$(nv p)" >"$envy_home/env/$(nv n)"
    nv g-- "$(nv p)" >>"$envy_home/env/$(nv n)"
    ;;

  #
  # No options or flags
  #

  all | .) nv g-- "." ;;

  cat) cat -- "$envy_home/env/$(nv rn "${2-$(nv n)}")" ;;

  cd)
    ! nv et "$2" && return 1
    nv n-- "$(nv en "$2")"
    nv p-- "$(nv ep "$2")"
    ;;

  edit)
    ! [ "$VISUAL" ] && echo "nv: Editor not specified in VISUAL environment variable" 1>&2 && return 1
    ! command -v -- "$VISUAL" >/dev/null &&
      echo "edit: $VISUAL: Editor not found" 1>&2 &&
      return 1

    shift
    if [ "$1" ]; then
      "$VISUAL" "$(nv w-- "$(nv rn "$1")")"
    else
      "$VISUAL" "$(nv home)"
    fi
    ;;

  exclude) printf %s\\n "$envy_exclude" ;;

  home) printf %s\\n "$envy_home" ;;

  isnew) case $(nv n) in */) ;; *) return 1 ;; esac ;;

  profile)
    shift && case $1 in
    '') nv rt "$envy_profile" && echo "$envy_profile" ;;
    *) __="$1" && shift && nv "profile-$__" "$@" ;;
    esac
    ;;
  profile-open--) # shellcheck disable=SC2046
    shift && [ "$1" ] && nv rt "$1" &&
      nv open $(cat -- "$envy_home/profile/$1") && envy_profile="$1" ;;
  profile-save--)
    shift && [ "$1" ] && nv rt "$1" &&
      nv na >"$envy_home/profile/$1" && envy_profile="$1" &&
      nv na
    ;;
  profile-find | profile-find--)
    find "$envy_home/profile" -type f -path "$envy_home/profile/${2-*}" | sort |
      while read -r file; do
        printf %s\\n "${file#$envy_home/profile/}"
      done
    ;;

  pwd) nv _e "$2" "pwd" && nv n ;;

  new)
    nv n-- "$2"
    nv p-- "${3-$(nv p)}"
    ;;

  set | set--)
    shift
    for __ in "$@"; do
      if ! printf %s "$__" | nv g-- "$(nv p)" - >/dev/null; then
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
      if ! printf %s "$__" | nv g-- "$(nv p)" - >/dev/null; then
        echo "unset: '$__': Not applicable to current environment" 1>&2
      else
        unset "$__"
      fi
    done
    ;;

  uninstall)
    nv ca
    # envy wide variables
    unset -v envy_home envy_exclude envy_profile
    # dangling variables local to functions
    unset -v _ __ __nv_cmd __nv_line
    unset -f nv
    ;;

  version | --version) echo "envy version 0.5.0" ;;

  which | w | which-- | w--)
    __="$envy_home/env/$2" && ! [ -f "$__" ] && ! [ -d "$__" ] &&
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

Shows current envionment variables and manages multiple environments.

Options
-a  show for all active environments
-f  find in saved environments
-h  help

Resource
d, domain    Print current environment name
n, name      Print/set current environment full name
p, pattern   Print/set current environment pattern
e, env       Print all opened environments or a specified environment

Environment Commands
., all       Show all managed environment variables
   cd        Change to an environment
c, close     Close environment
   ls, na    Print active environment names
   new       Create a new unsaved environment for a name and pattern
n, pwd       Print name of current environment

Environment Variable Commands
   get       Get a current environemnt variable by name
   set       Set a current envionrment variable
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

envy_home="${ENVY_HOME-$HOME/.config/envy}"

# native environment variables, expands variables
# No restriction (may set PATH, etc.) except for envy_* and ENVY_HOME
[ -f "$envy_home/.nvrc" ] &&
  while read -r __ || [ "$__" ]; do
    case $__ in
    '' | \#*) continue ;;
    envy_*=* | ENVY_HOME=*) echo "nvrc: ${__%%=*}: Ignoring invalid environment variable" 1>&2 ;;
    *=*) export "${__%%=*}"="$(eval 'printf %s "'"${__#*=}"'"')" ;;
    *) echo "nvrc: $__: Ignoring invalid nvrc statement" 1>&2 ;;
    esac
  done <"$envy_home/.nvrc"

envy_exclude="${ENVY_EXCLUDE-COLOR|COMMAND_|EDITOR=|ENVY_|HOSTNAME=|HOME=|LANG=|LaunchInstanceID=|LOGNAME=|ITERM_|LC_|OLDPWD=|PATH=|PWD=|SECURITYSESSIONID=|SHELL=|SHLVL=|SSH_|TERM=|TERM_|TMPDIR=|VSCODE_|USER|VISUAL=|XPC_|_=|__${ENVY_EXCLUDE_APPEND:+|$ENVY_EXCLUDE_APPEND}}"
envy_profile="${ENVY_PROFILE-nv}"

[ -f "$envy_home/profile/$envy_profile" ] && nv profile open -- "$envy_profile"

mkdir -p -- "$envy_home/env"
mkdir -p -- "$envy_home/profile"

#
# must source to use nv: . envy.sh
#
