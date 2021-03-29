# shellcheck shell=sh
nv() {
  # shellcheck disable=SC2046
  case $1 in
  #
  # Options
  #
  --version | version) echo "envy version 0.7.1" ;;
  + | -[!h] | \
    shell | shell^* | %* | \
    work | work^* | ^* | \
    '' | env | env^* | . | .* | \
    */*)

    case $1 in
    '') set -- '-i' '.' "$@" ;;
    +) shift ;;
    -*) ;;
    *) set -- '-i' "$@" ;;
    esac

    _nv_first=0 _nv_options=0
    for param; do
      [ "$_nv_first" ] && set -- && unset -v _nv_first

      if ! [ "$_nv_options" ]; then
        set -- "$@" "$param"
        continue
      fi

      case $param in
      env) param='.' ;;
      shell) param='%' ;;
      work) param='^' ;;
      env^*) param=".${param#env^}" ;;
      shell^*) param="%${param#shell^}" ;;
      work^*) param="^${param#work^}" ;;
      [![:alpha:]]* | */*/* | *^*) ;;
      */ | */[[:alpha:]] | */[[:alpha:]]*[[:alpha:]]) param="$param^" ;;
      esac

      case $param in
      %*)
        for _nv_name in $(nv gs-- "${param#?}"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;
      .*)
        for _nv_name in $(nv g-- "${param#?}"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;
      ^*)
        for _nv_name in $(nv g-- "${param#?}" | grep -E -e "$(nv p)"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;

      -*) set -- "$@" "$param" ;;
      [![:alpha:]]* | */*/*) set -- "$@" "$param" && unset -v _nv_options ;;

      */^*) # domiain/^GREP
        ! _nv_ep=$(nv ep-- "${param%%/*}") && echo "nv: $param: domain not open" 1>&2 && nv na 1>&2 &&
          return 1

        for __ in $(nv g-- "${param#*^}" | grep -E -e "$_nv_ep"); do
          set -- "$@" "$__=$(printenv -- "$__")"
        done
        ;;
      */[[:alpha:]]*^*) # domain/name^GREP
        _nv_grep=${param#*^}
        exec 3<"$ENVY_HOME/env/${param%%^*}"
        while read -r || [ "$REPLY" ]; do
          case $REPLY in
          \#* | '') continue ;;
          *=*)
            ! nv vnt-- "${REPLY%%=*}" "$_nv_grep" &&
              continue

            set -- "$@" "$REPLY"
            ;;
          *\<\<*)
            _nv_name=${REPLY%%<<*} _nv_delim=${REPLY#*<<}
            ! nv vnt-- "$_nv_name" "$_nv_grep" &&
              continue

            _nv_delim=${REPLY#*<<}
            unset _nv_value
            while read -r || [ "$REPLY" ]; do
              [ "$REPLY" = "$_nv_delim" ] && break
              _nv_value="${_nv_value+$_nv_value
}$REPLY"
            done <&3

            set -- "$@" "$_nv_name=$_nv_value"
            ;;
          esac
        done <&3
        ;;
      *)
        set -- "$@" "$param"
        unset -v _nv_options
        ;;
      esac
    done

    if [ "${edr+.}" ]; then
      echo env "$@"
    else
      env "$@"
    fi
    ;;

  #
  # Commands and no argument
  #

  close | c | close-a | ca | \
    domain | d | domain-a | da | domain-u | du | domain-f | df | \
    export | x | export-p | exclude | \
    name | n | name-a | na | new | \
    pattern | p | pattern-a | pa | pattern-c | pc | pattern-s | ps | \
    unset | unset-v | unset-a | ua | unset-p | pu | \
    switch | \
    cat | \
    edit | \
    find | f | find-a | fa | gn | \
    open | o | \
    profile-open | profile-save | \
    save | s | \
    grep | g | grep-s | gs | \
    home | isnew | \
    which | w)

    _nv_cmd=$1

    # look ahead
    shift && case $1 in
    '')
      # commands or options with no argument
      case $_nv_cmd in

      # Working environment

      close | c) nv c-- "$(nv rd-- "$envy_name")" ;;
      close-a | ca)
        for __ in $(nv da); do
          nv ec-- "$__"
        done
        unset -v envy_name ENVY_PATTERN
        ;;

      domain | d) nv rd-- "$envy_name" ;;
      domain-a | da)
        set | grep -e '^envy_env_' | while IFS='=' read -r key _; do
          printf %s\\n "${key#envy_env_}"
        done
        ;;
      domain-f | df) nv df-- "" ;;
      domain-u | du) nv eu-- "$(nv d)" ;;

      export | x | export-p)
        echo "ENVY_PATTERN=$(nv p)"
        for _nv_name in $(nv g-- "$(nv p)"); do
          if [ "$(printf %s "$(printenv -- "$_nv_name")" | wc -l)" -eq 0 ]; then
            printf '%s=%s\n' "$_nv_name" "$(printenv -- "$_nv_name")"
          else
            printf "%s<<___.,-,.___\\n" "$_nv_name"
            printf %s "$(printenv -- "$_nv_name")" | while read -r || [ "$REPLY" ]; do
              printf '%s\n' "$REPLY"
            done
            printf '%s\n' "___.,-,.___"
          fi
        done | grep .
        ;;

      isnew) case $(nv n) in */) ;; *) return 1 ;; esac ;;

      name | n) nv rn-- "$envy_name" ;;
      name-a | na)
        for __ in $(nv da); do
          nv en-- "$__"
        done | grep .
        ;;

      pattern | p) printf %s\\n "${ENVY_PATTERN-.}" ;;
      pattern-a | pa)
        for __ in $(nv da); do
          nv ep-- "$__"
        done | grep .
        ;;
      pattern-c | pc) nv up && unset -v ENVY_PATTERN ;;
      pattern-s | ps) printf %s\\n "$envy_shell" ;;

      unset-a | ua) nv ua-- $(nv g-- .) ;;
      unset-p | up) nv ua-- $(nv g-- "$(nv p)") ;;

      # Environment File

      cat) nv cat-- "$envy_name" ;;

      find | f) nv f-- "*" ;;
      find-a | fa) nv fa-- "*" ;;

      open | o) nv o-- "$envy_name" ;;

      profile-find) nv profile-find-- "*" ;;
      profile-open) nv profile-open-- "$envy_profile" ;;
      profile-save) nv profile-save-- "$envy_profile" ;;

      save | s) nv s-- "$envy_name" ;;

      # Other Commands

      home) printf %s\\n "$ENVY_HOME" ;;

      *) nv "$_nv_cmd--" ;;
      esac
      ;;
    -*) __="$1" && shift && nv "$_nv_cmd$__" "$@" ;;
    *) nv "$_nv_cmd--" "$@" ;;
    esac
    ;;

  #
  # Working Environment Commands
  #

  close-- | c--) shift && nv ec-- "$1" && nv n-- "" ;;

  domain-f-- | df--)
    shift && for __; do
      find "$ENVY_HOME/env" -mindepth 1 -maxdepth 1 -type d -path "*$__" | while read -r file; do
        printf %s\\n "${file#$ENVY_HOME/env/}"
      done
    done | grep .
    ;;

  # get information for an environment
  es--)
    [ "${2+x}" ] && __="$(eval 'echo $envy_env_'"$(nv rd-- "$2")")" && [ "$__" ] &&
      echo "$__"
    ;;
  ec--) nv eu-- "$2" && unset envy_env_"$2" ;;
  en--) __="$(nv es-- "$2")" && printf %s\\n "${__%% *}" ;;
  ep--) __="$(nv es-- "$2")" && printf %s\\n "${__#* }" ;;
  et--) nv es-- "$2" 1>/dev/null ;;
  eu--) __="$(nv ep-- "$2")" && unset -v $(nv g-- "$__") ;;

  # variable name test
  vnt--) printf %s "$2" | grep -E -e "^[_A-Za-z][_A-Za-z0-9]*$" |
    grep -E -e "^($3)" | grep -qvE -e "^($envy_shell)" ;;

  export-- | x--)
    shift && [ "${1+.}" ] && for __; do
      if nv vnt-- "${__%%=*}" "$(nv p)"; then
        # shellcheck disable=SC2163
        export -- "$__"
      else
        echo "nv: export: $__: bad variable name" 1>&2
      fi
    done
    ;;

  name-- | n--) [ "${2+x}" ] && __=$(nv rn-- "$2") && envy_name=$__ && echo "$__" ;;

  new--)
    nv n-- "$2"
    nv p-- "${3-$(nv p)}"
    ;;

  pattern-- | p--) [ "${2+x}" ] && export ENVY_PATTERN="$2" ;;

  printenv | pe) shift && nv . printenv "$@" ;;

  switch--)
    ! nv et-- "$2" && return 1
    nv n-- "$(nv en-- "$2")"
    nv p-- "$(nv ep-- "$2")"
    ;;

  unset-- | unset-v-- | u--)
    shift && [ "$1" ] && for __; do
      nv vnt-- "$__" "$(nv p)" && unset -v -- "$__"
    done
    ;;

  unset-a-- | ua--)
    shift && [ "$1" ] && for __; do
      nv vnt-- "$__" && unset -v -- "$__"
    done
    ;;

  #
  # Environment File Commands
  #

  cat--) shift && cat -- "$ENVY_HOME/env/$(nv rn-- "$1")" ;;

  diff)
    shift && ! [ "${1+.}" ] && set -- "$(nv n)" -

    _nv_first=0 _nv_files=0
    for param; do
      [ "$_nv_first" ] && set -- && unset -v _nv_first
      case $param in
      */*)
        ! __=$(nv w-- "$param") && return 1
        set "$@" "$__"
        _nv_files=$((_nv_files + 1))
        ;;
      -) _nv_files=$((_nv_files + 1)) ;;
      *) set "$@" "$param" ;;
      esac
    done

    case $_nv_files in
    0) set "$@" "$(nv w-- "$(nv n)")" - ;;
    1) set "$@" - ;;
    esac

    if [ "${edr+.}" ]; then
      echo nv export "|" diff "$@"
    else
      nv export | diff "$@"
    fi

    ;;

  edit--)
    ! [ "$VISUAL" ] && echo "nv: Editor not specified in VISUAL environment variable" 1>&2 && return 1
    ! command -v -- "$VISUAL" >/dev/null &&
      echo "edit: $VISUAL: Editor not found" 1>&2 &&
      return 1

    shift
    if [ "$1" ]; then
      for __; do
        "$VISUAL" "$(nv w-- "$(nv rn-- "$__")")"
      done
    else
      "$VISUAL" "$(nv home)"
    fi
    ;;

  find-- | f--)
    shift && for __; do
      find "$ENVY_HOME/env" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/env/$(nv d)/$__" |
        while read -r; do
          printf %s\\n "${REPLY#$ENVY_HOME/env/}"
        done
    done | grep .
    ;;
  find-a-- | fa--)
    shift && for __; do
      find "$ENVY_HOME/env" -mindepth 2 -maxdepth 2 -type f -path "$ENVY_HOME/env/$__" |
        while read -r; do
          printf %s\\n "${REPLY#$ENVY_HOME/env/}"
        done
    done | grep .
    ;;

  open-- | o--)
    shift && [ "$1" ] && for __; do
      ! nv n-- "$__" && return 1
      nv isnew && continue

      # unset new domain set above
      nv du

      exec 3<"$ENVY_HOME/env/$(nv n)"
      while read -r || [ "$REPLY" ]; do
        case $REPLY in
        \#* | '') continue ;;
        ENVY_PATTERN=*) nv p-- "${REPLY#*=}" ;;
        *=*) nv x-- "$REPLY" ;;
        *\<\<*)
          unset _nv_value
          _nv_name=${REPLY%%<<*} _nv_delim=${REPLY#*<<}
          while read -r || [ "$REPLY" ]; do
            [ "$REPLY" = "$_nv_delim" ] && break
            _nv_value="${_nv_value+$_nv_value
}$REPLY"
          done <&3
          nv x-- "$_nv_name=$_nv_value"
          ;;
        *) echo "nv: open: $REPLY: line ignored" 1>&2 ;;
        esac
      done <&3

      eval 'envy_env_'"$(nv d)"'="$(nv n) $(nv p)"'
      printf '%s\n' "$(nv p)"
    done
    ;;

  profile)
    # handle sub commands here
    shift && case $1 in
    '') nv rt-- "$envy_profile" && echo "$envy_profile" ;;
    *) __="$1" && shift && nv "profile-$__" "$@" ;;
    esac
    ;;
  profile-open--)
    shift && [ "$1" ] && nv rt-- "$1" &&
      nv o-- $(cat -- "$ENVY_HOME/profile/$1") && envy_profile="$1"
    ;;
  profile-save--)
    shift && [ "$1" ] && nv rt-- "$1" &&
      nv na >"$ENVY_HOME/profile/$1" && envy_profile="$1" &&
      nv na
    ;;
  profile-find--)
    shift && for __; do
      find "$ENVY_HOME/profile" -type f -path "$ENVY_HOME/profile/$__" | sort |
        while read -r file; do
          printf %s\\n "${file#$ENVY_HOME/profile/}"
        done | grep .
    done
    ;;

  rn--)
    nv rt-- "$2" && case $2 in
    */*) echo "$2" ;;
    *) echo "$(nv rd--)/$2" ;;
    esac
    ;;
  rt--)
    # resolve test name
    case $2 in
    /*)
      echo "name: $2: may not have a leading slash" 1>&2
      return 1
      ;;
    *[![:alnum:]/_]* | [[:digit:]]*)
      echo "name: $2: may only contain alphanumeric or underscore" 1>&2
      return 1
      ;;
    */*/*)
      echo "name: $2: may only have one path separator" 1>&2
      return 1
      ;;
    *) return 0 ;;
    esac
    ;;
  rd--)
    nv rt-- "$2" && case $2 in
    */*) echo "${2%/*}" ;;
    '') if [ "$envy_name" ]; then nv rd-- "$envy_name"; else echo 'nv'; fi ;;
    *) echo "$2" ;;
    esac
    ;;

  save-- | s--)
    shift && ! [ "$1" ] && return 1
    ! nv n-- "$1" && return 1

    # if still new (name wasn't assigned above)
    nv isnew && echo "save: Must provide a new environment name" 1>&2 && return 1

    eval 'envy_env_'"$(nv d)"'="$(nv n) $(nv p)"'
    mkdir -p -- "$ENVY_HOME/env/$(nv d)"
    nv x >"$ENVY_HOME/env/$(nv n)"
    ;;

  which-- | w--)
    __="$ENVY_HOME/env/$2" && ! [ -f "$__" ] && ! [ -d "$__" ] &&
      echo "$2 not found" 1>&2 &&
      return 1
    printf %s\\n "$__"
    ;;

  #
  # Other Commands
  #

  grep-- | g--) shift && nv ga-- "$@" | grep -vE -e "^($envy_shell)" ;;

  grep-s-- | gs--) shift && nv ga-- "$@" | grep -E -e "^($envy_shell)" ;;

  grep-a-- | ga--) shift && awk 'BEGIN{for(v in ENVIRON) print v}' |
    sort | grep -E -e "^($1)" ;;

  help | -h | --help)
    shift && case $1 in
    '') nv h-- ;;
    *) nv "help-$1" "$@" ;;
    esac
    ;;

  h--)
    cat <<EOF
 _____ ____ _   _ _   _ 
 | ___ |  _ \ | | | | | |
 | ____| | | \ V /| |_| |
 |_____)_| |_|\_/  \__  |
                  (____/ 

usage:  nv [OPTIONS] | [NAME=VALUE]

Show and manage program envionment variables.  Envy differs from
env, export, printenv and unset in that it does not by default show 
shell environment variables like TERM, HOME, PATH.

Examples of program environment variables are GIT_* for git, AWS_* 
for aws-cli, and so on.

Options
.,  env       Non shell environment variables
/,  work      Working domain environment variables
%,  shell     Shell environment variables
^[pattern]    Grep non shell environment variables by name
+             All environment variables
-u, --unset   Unset variable for program to execute, only applicable after + 
-h, --help    Show help a sub command
--version     Print version information

Working Environment Commands
c, close     Close environment
d, domain    Print current domain name
x, export    Set the export attribute for working environment variables
   isnew     Check if new working environment
   na        Print active environment names
n, name      Print/set curent domain full name
   new       Create a new unsaved working environment for a name and pattern
p, pattern   Print/set current domain environment variable name pattern
   printenv  Print all or part of the working environment
   switch    Switch working environment
u, unset     Unset a working environment variable

Environment File
   cat      Print an environment file
   edit     Edit an environment file using ${VISUAL-** VISUAL environment variable not set **)}
f, find     Find all environment files
o, open     Open a new environment from file
   profile  Find, open and save profiles
s, save     Save or replace the environment
w, which    Print full file path to saved environment

Other Commands
   grep        Grep environment variable names
   help        Show this help
   home        Show environment file home directory
   version     Print the version information
EOF
    ;;
  help-close | help-c | close-h | c-h) echo "usage: close -aehp" ;;
  help-env | help-e | env-h | e-h) echo "usage: env -acnptu" ;;

  help-export | help-x | export-h | x-h)
    cat <<'eof'
usage:  nv export name[=word]...

Set the export attribute for current variables

Options
-p  write to the standard output the names and values of all exported variables 
-h  help

Description

The shell shall give the export attribute to the variables
corresponding to the specified names, which shall cause them to
be in the environment of subsequently executed commands. If the
name of a variable is followed by =word, then the value of that
variable shall be set to word.

When -p is specified, export shall write to the standard output
the names and values of all exported variables, in the following
ouput suitable for serialization:

"%s=%s\n", <name>, <value>

for single line variables and:

name<<____
value...
___

for multi line variables.
eof
    ;;

  help-name | help-n | name-h | n-h) echo "usage: name -afh" ;;
  help-pattern | help-p | pattern-h | ph) echo "usage: name -achu" ;;
  help-printenv | printenv-h)
    cat <<'eof'
usage:  nv printenv [OPTION] [VARIABLE]...

Print all or part of the working environment

Options
-p  print name and value pairs
-h  help

Description

Print the values of the specified environment VARIABLE(s).  If no
VARIABLE is specified, print name and value pairs for them all.
eof
    ;;
  help-resolve | help-r | resolve-h | r-h) echo "usage: resolve -dnth" ;;
  help-unset | unset-h)
    cat <<'eof'
usage:  nv unset [-v] NAME... | [-ae]

Unset values and attributes of variables in current environment.

Options
-a  unset all
-p  unset current pattern
-v  provided for compatibility, unset only unsets variables
-h  help

Description

Each variable specified by name shall be unset.

Unsetting a variable or function that was not previously set
shall not be considered an error and does not cause the shell to
abort.

eof
    ;;
  help-domain | domain-h) echo "usage: domain -afu" ;;

  -*) echo "nv: $1: Unknown option" 1>&2 && nv -h 1>&2 && return 1 ;;

  *=*) nv x-- "$1" ;;

  *)
    if printf %s "$1" | grep -qE -e '^([[:upper:]]|_)([[:alpha:]]|_|[[:digit:]])*$'; then
      nv . printenv "$@"
    else
      echo "nv: $(printf '%s ' "$@"): Unknown resource or command" 1>&2 && nv -h 1>&2 && return 1
    fi
    ;;
  esac
}

#
# Initailize envy
#

export ENVY_HOME="${ENVY_HOME-$HOME/.config/envy}"
readonly ENVY_HOME
unset ENVY_PATTERN

[ -f "$ENVY_HOME/.nvrc" ] &&
  # load extension to shell environment
  exec 3<"$ENVY_HOME/.nvrc" &&
  while read -r || [ "$REPLY" ]; do
    case $REPLY in
    '' | \#*) continue ;;
    *=*)
      _nv_name="${REPLY%%=*}" _nv_value="${REPLY#*=}"
      ;;
    *\<\<*)
      unset _nv_value
      _nv_name=${REPLY%%<<*} _nv_delim=${REPLY#*<<}
      while read -r || [ "$REPLY" ]; do
        [ "$REPLY" = "$_nv_delim" ] && break
        _nv_value="${_nv_value+$_nv_value
}$REPLY"
      done <&3
      ;;
    *) echo "nvrc: $REPLY: Ignoring invalid nvrc statement" 1>&2 ;;
    esac

    # export and process within here-doc for expansions
    export -- "$_nv_name=$(
      eval 'cat <<ff483722-a9e5-4438-8b00-28ae9f416136
'"$_nv_value"'
ff483722-a9e5-4438-8b00-28ae9f416136'
    )"
  done <&3

readonly envy_shell="${ENVY_SHELL-COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOME$|LANG$|LaunchInstanceID$|LOGNAME$|ITERM_|LC_|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VSCODE_|USER|VISUAL$|XPC_|_$|__${ENVY_SHELL_APPEND:+|$ENVY_SHELL_APPEND}}"
envy_profile="${ENVY_PROFILE-nv}"

if [ -f "$ENVY_HOME/profile/$envy_profile" ]; then
  nv profile-open-- "$envy_profile"
else
  # if no profile set above, set default name
  envy_name=nv/default
  [ -f "$ENVY_HOME/env/nv/default" ] && nv o-- nv/default
fi

# ensure directories
mkdir -p -- "$ENVY_HOME/env"
mkdir -p -- "$ENVY_HOME/profile"

#
# must source to use nv: . envy.sh
#
