# shellcheck shell=sh
nv() {
  # shellcheck disable=SC2046
  case $1 in

  #
  # Options
  #

  '') nv pep ;;
  -g) shift && nv peap-- $(nv peg-- "$1") ;;
  --unset | -u)
    shift
    nv unset-- "$1"
    nv pep
    ;;
  --version | version) echo "envy version 0.6.0" ;;

  #
  # Commands
  #

  . | -a | cat | cd | close | c | close-a | ca | \
    domain | d | domain-a | da | domain-u | du | domain-f | df | \
    edit | env | e | env-a | ea | env-c | ec | env-n | en | env-p | ep | env-t | et | env-u | eu | \
    export | x | export-p | export-d | exclude | \
    find | f | find-a | fa | gn | \
    home | isnew | \
    name | n | name-a | ls | na | new | \
    open | o | \
    pattern | p | pattern-a | pa | pattern-c | pc | \
    printenv | pe | printenv-p | pep | printenv-ap | peap | printenv-n | pen | printenv-an | pean | \
    profile-open | profile-save | save | s | \
    unset | unset-v | unset-a | ua | unset-p | pu | \
    pwd | which | w)

    _nv_cmd=$1

    # look ahead
    shift && case $1 in
    '')
      # commands or options with no argument
      case $_nv_cmd in
      cat) nv cat-- "$envy_name" ;;
      close | c) nv c-- "$(nv rd-- "$envy_name")" ;;
      close-a | ca)
        for __ in $(nv da); do
          nv ec-- "$__"
        done
        unset -v envy_name envy_pattern
        ;;
      domain | d) nv rd-- "$envy_name" ;;
      domain-a | da)
        set | grep -e '^envy_env_' | while IFS='=' read -r key _; do
          printf %s\\n "${key#envy_env_}"
        done
        ;;
      domain-f | df) nv df-- "" ;;
      domain-u | du) nv eu-- "$(nv d)" ;;
      env-a | ea)
        for __ in $(nv da); do
          printf %s\\n "$(nv e-- "$__")"
        done
        ;;
      env-n | en) nv na ;;
      env-p | ep) nv pa ;;
      exclude) printf %s\\n "$envy_exclude" ;;
      export | x | export-p)
        for _nv_name in $(nv pen); do
          if [ "$(printf %s "$(printenv "$_nv_name")" | wc -l)" -eq 0 ]; then
            printf '%s=%s\n' "$_nv_name" "$(printenv "$_nv_name")"
          else
            printf "%s<<___.,-,.___\\n" "$_nv_name"
            printf %s "$(printenv "$_nv_name")" | while read -r || [ "$REPLY" ]; do
              printf '%s\n' "$REPLY"
            done
            printf '%s\n' "___.,-,.___"
          fi
        done | grep -e "."
        ;;
      find | f) nv f-- "*" ;;
      find-a | fa) nv fa-- "*" ;;
      home) printf %s\\n "$envy_home" ;;
      isnew) case $(nv n) in */) ;; *) return 1 ;; esac ;;
      name | n) nv rn-- "$envy_name" ;;
      name-a | ls | na)
        for __ in $(nv da); do
          nv en-- "$__"
        done | grep -e "."
        ;;
      open | o) nv o-- "$envy_name" ;;
      pattern | p) printf %s\\n "${envy_pattern-.}" ;;
      pattern-a | pa)
        for __ in $(nv da); do
          nv ep-- "$__"
        done | grep -e "."
        ;;
      pattern-c | pc) nv up && unset -v envy_pattern ;;
      printenv | pe | printenv-p | pep | env | e) nv -g "$(nv p)" ;;
      printenv-n | pen) nv peg-- "$(nv p)" ;;
      printenv-an | pean) nv peg-- ;;
      . | -a | printenv-ap | peap) nv -g ;;
      profile-find) nv profile-find-- "*" ;;
      profile-open) nv profile-open-- "$envy_profile" ;;
      profile-save) nv profile-save-- "$envy_profile" ;;
      pwd) nv n ;;
      save | s) nv s-- "$envy_name" ;;
      uninstall)
        nv ca
        # envy wide variables
        unset -v envy_home envy_exclude envy_profile
        # dangling variables local to functions
        unset -v _ __ _nv_cmd __nv_line
        unset -f nv
        ;;
      unset-a | ua) unset -v $(nv peg--) ;;
      unset-p | up) unset -v $(nv pen) ;;
      *) nv "$_nv_cmd--" ;;
      esac
      ;;
    -*) __="$1" && shift && nv "$_nv_cmd$__" "$@" ;;
    *) nv "$_nv_cmd--" "$@" ;;
    esac
    ;;

  cat--) shift && cat -- "$envy_home/env/$(nv rn-- "$1")" ;;

  cd--)
    ! nv et-- "$2" && return 1
    nv n-- "$(nv en-- "$2")"
    nv p-- "$(nv ep-- "$2")"
    ;;

  close-- | c--) shift && nv ec-- "$1" && nv n-- "" ;;

  domain-f-- | df--)
    shift && for __; do
      find "$envy_home/env" -mindepth 1 -maxdepth 1 -type d -path "*$__" | while read -r file; do
        printf %s\\n "${file#$envy_home/env/}"
      done
    done | grep -e "."
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

  # get information for an environment
  env-- | e--)
    [ "$2" ] && __="$(eval 'echo $envy_env_'"$(nv rd-- "$2")")" && [ "$__" ] &&
      echo "$__"
    ;;
  env-c-- | ec--) nv eu-- "$2" && unset envy_env_"$2" ;;
  env-n-- | en--) __="$(nv e-- "$2")" && printf %s\\n "${__%% *}" ;;
  env-p-- | ep--) __="$(nv e-- "$2")" && printf %s\\n "${__#* }" ;;
  env-t-- | et--) nv e-- "$2" 1>/dev/null ;;
  env-u-- | eu--) __="$(nv ep-- "$2")" && unset -v $(nv peg-- "$__") ;;

  export-- | x--)
    shift
    for __; do
      if nv export-d-- "$__" >/dev/null; then
        # shellcheck disable=SC2163
        export "$__"
      else
        echo "nv: export: '$__': bad variable name" 1>&2
      fi
    done
    ;;
  export-d--) printf %s "$2" | nv gnr-- "$(nv p)" ;;

  find-- | f--)
    shift && for __; do
      find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/$(nv d)/$__" |
        while read -r; do
          printf %s\\n "${REPLY#$envy_home/env/}"
        done
    done | grep -e "."
    ;;
  find-a-- | fa--)
    shift && for __; do
      find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/$__" |
        while read -r; do
          printf %s\\n "${REPLY#$envy_home/env/}"
        done
    done | grep -e "."
    ;;

  var-name--) printf %s "$2" | grep -E -e "^[_A-Za-z][_A-Za-z0-9]*$" | grep -E -e "^($3)" | grep -qvE -e "^($envy_exclude)" ;;

  gn--)
    # this is a lot of work just to get names, should be easier
    shift && nv gnr-- "^($1)" | sort |
      while read -r; do
        printenv "$REPLY" 1>/dev/null && printf '%s\n' "$REPLY"
      done | grep -e "."
    ;;
  gnr--)
    grep -oE -e "^[_A-Za-z][_A-Za-z0-9]*(=|<<)" | grep -oE -e "^[_A-Za-z][_A-Za-z0-9]*" |
      grep -E -e "^($2)" | grep -vE -e "^($envy_exclude)"
    ;;

  name-- | n--) [ "${2+x}" ] && __=$(nv rn-- "$2") && envy_name=$__ && echo "$__" ;;

  new--)
    nv n-- "$2"
    nv p-- "${3-$(nv p)}"
    ;;

  open-- | o--)
    shift && ! [ "$1" ] && return 1
    for __; do
      ! nv n-- "$__" && return 1
      nv isnew && continue

      # unset new domain set above
      nv du

      exec 3<"$envy_home/env/$(nv n)"
      while read -r || [ "$REPLY" ]; do
        case $REPLY in
        \#* | '') continue ;;
        +*)
          nv p-- "${REPLY#*+}"
          eval 'envy_env_'"$(nv d)"'="$(nv n) $(nv p)"'
          ;;
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
    done
    ;;

  pattern-- | p--) [ "${2+x}" ] && envy_pattern="$2" ;;

  printenv-- | pe--) # current environment values
    shift && nv pea-- $(printf %s "$@" | grep -E -e "^($(nv p))")
    ;;
  printenv-a-- | pea--) # all environment values
    shift && for _nv_name; do
      nv var-name-- "$_nv_name" && printenv "$_nv_name"
    done
    ;;
  printenv-p-- | pep--) # current environment pairs
    shift && nv peap-- $(printf %s "$@" | grep -E -e "^($(nv p))")
    ;;
  printenv-ap-- | peap--) # all environment pairs
    shift && for _nv_name; do
      nv var-name-- "$_nv_name" && _nv_value=$(printenv "$_nv_name") &&
        printf '%s=%s\n' "$_nv_name" "$_nv_value"
    done
    ;;
  printenv-n-- | pen--) shift && printf %s "$@" | nv gn-- "$(nv p)" ;;
  printenv-an-- | pean--) shift && printf %s "$@" | nv gn-- ;;
  printenv-g-- | peg--) shift && env | nv gn-- "$1" ;;

  profile)
    # handle sub commands here
    shift && case $1 in
    '') nv rt-- "$envy_profile" && echo "$envy_profile" ;;
    *) __="$1" && shift && nv "profile-$__" "$@" ;;
    esac
    ;;
  profile-open--)
    shift && [ "$1" ] && nv rt-- "$1" &&
      nv o-- $(cat -- "$envy_home/profile/$1") && envy_profile="$1"
    ;;
  profile-save--)
    shift && [ "$1" ] && nv rt-- "$1" &&
      nv na >"$envy_home/profile/$1" && envy_profile="$1" &&
      nv na
    ;;
  profile-find--)
    shift && for __; do
      find "$envy_home/profile" -type f -path "$envy_home/profile/$__" | sort |
        while read -r file; do
          printf %s\\n "${file#$envy_home/profile/}"
        done | grep -e "."
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

    mkdir -p -- "$envy_home/env/$(nv d)"
    printf %s\\n "+$(nv p)" >"$envy_home/env/$(nv n)"
    nv export >>"$envy_home/env/$(nv n)"
    ;;

  unset-- | unset-v--)
    shift && for __; do
      nv var-name-- "$__" "$(nv p)" && unset "$__"
    done
    ;;

  which-- | w--)
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
., -a, --all  Print all environment variables 
-g            Grep all environment variables by name
-u, --unset   Remove variable from the current environment
-h, --help    Help
--version     Print version information

Resource
d, domain    Print current environment domain name
n, name      Print/set current environment full name
p, pattern   Print/set current environment pattern

Environment Commands
e, env       Print current environment or a specified environment
   export    Set the export attribute for current variables
   cd        Change to an environment
c, close     Close environment
   ls, na    Print active environment names
   new       Create a new unsaved environment for a name and pattern
   printenv  Print all or part of the current environment 
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
    uninstall   Unset everything and uninstall nv function
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

Print all or part of the current environment

Options
-a  print name and value pairs for all environments
-n  print current environment names
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
  [[:alpha:]]*=*) nv x "$1" ;;
  *)
    if printf %s "$1" | grep -qE -e '^([[:upper:]]|_)([[:upper:]]|_|[[:digit:]])*$'; then
      nv pe-- "$1"
    else
      echo "nv: $(printf '%s ' "$@"): Unknown resource or command" 1>&2 && nv -h 1>&2 && return 1
    fi
    ;;
  esac
}

#
# Initailize envy
#

envy_home="${ENVY_HOME-$HOME/.config/envy}"

[ -f "$envy_home/.nvrc" ] &&
  # native environment variables evaluated in here-document
  exec 3<"$envy_home/.nvrc" &&
  while read -r || [ "$REPLY" ]; do
    case $REPLY in
    '' | \#*) continue ;;
    envy_* | _nv* | ENVY_HOME*) echo "nvrc: ${REPLY%%=*}: Ignoring local environment variable" 1>&2 && continue ;;
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
    export "$_nv_name=$(
      eval 'cat <<ff483722-a9e5-4438-8b00-28ae9f416136
'"$_nv_value"'
ff483722-a9e5-4438-8b00-28ae9f416136'
    )"
  done <&3

envy_exclude="${ENVY_EXCLUDE-COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOME$|LANG$|LaunchInstanceID$|LOGNAME$|ITERM_|LC_|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VSCODE_|USER|VISUAL$|XPC_|_$|__${ENVY_EXCLUDE_APPEND:+|$ENVY_EXCLUDE_APPEND}}"
envy_profile="${ENVY_PROFILE-nv}"

[ -f "$envy_home/profile/$envy_profile" ] && nv profile open -- "$envy_profile"

# if no profile set above, set default name
envy_name="${envy_name-nv/default}"

mkdir -p -- "$envy_home/env"
mkdir -p -- "$envy_home/profile"

#
# must source to use nv: . envy.sh
#
