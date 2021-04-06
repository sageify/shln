# shellcheck shell=sh
nv() {
  [ $# -eq 0 ] && set -- '-i' '/'

  # shellcheck disable=SC2046,SC2154
  case $1 in
  *=*)
    # Trigger export before external env -  variable value could match improperly
    nv x-- "$@"
    ;;

  -* | *.* | */* | %* | @*)
    # Trigger external env command
    case $1 in
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

      # remap some parameters
      case $param in
      @*) param=$(nv n).${param#@} ;;
      [[:alnum:]_]*/*.*) ;;
      [[:alnum:]_]*/*) param="$param." ;;
      esac

      case $param in
      %*)
        for _nv_name in $(nv gs-- "${param#%}"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;
      /*)
        for _nv_name in $(nv g-- "${param#/}"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;
      .*)
        for _nv_name in $(nv g-- "${param#.}" | grep -E -e "$(nv p)"); do
          set -- "$@" "$_nv_name=$(printenv -- "$_nv_name")"
        done
        ;;

      -*) set -- "$@" "$param" ;;

      [![:alnum:]_]*) set -- "$@" "$param" && unset -v _nv_options ;;

      */*.*) # domain/name.PATTERN
        _nv_grep="${param#*.}"

        exec 3<"$envy_home/env/${param%%.*}"
        while IFS= read -r _nv_line || [ "$_nv_line" ]; do
          case $_nv_line in
          \#* | '') continue ;;
          *=*)
            ! nv vnt-- "${_nv_line%%=*}" "$_nv_grep" &&
              continue
            set -- "$@" "$_nv_line"
            ;;
          *\<\<*)
            _nv_name=${_nv_line%%<<*}
            ! nv vnt-- "$_nv_name" "$_nv_grep" &&
              continue
            _nv_delim=${_nv_line#*<<}
            unset -v _nv_value
            while IFS= read -r _nv_line || [ "$_nv_line" ]; do
              [ "$_nv_line" = "$_nv_delim" ] && break
              _nv_value="${_nv_value+$_nv_value
}$_nv_line"
            done <&3

            set -- "$@" "$_nv_name=$_nv_value"
            ;;
          esac
        done <&3
        ;;
      *.*) # domiain.PATTERN
        ! _nv_ep=$(nv ep-- "${param%%.*}") && echo "nv: $param: domain not open" 1>&2 && nv na 1>&2 &&
          return 1
        for __ in $(nv g-- "${param#*.}" | grep -E -e "$_nv_ep"); do
          set -- "$@" "$__=$(printenv -- "$__")"
        done
        ;;

      *) set -- "$@" "$param" && unset -v _nv_options ;;
      esac
    done

    if [ "${edr+.}" ]; then
      echo env "$@"
    else
      env "$@"
    fi
    ;;

  cat | cd | code | cp | diff | edit | ls | mkdir | mv | nano | rm | vi | vim)
    # Build generic external command with name expansion
    _nv_first=0 _nv_no_input=0 _nv_no_args=0
    for param; do
      if [ "$_nv_first" ]; then
        unset -v _nv_first
        if [ "$param" = edit ]; then
          ! [ "$VISUAL" ] &&
            echo "nv: Editor not specified in VISUAL environment variable" 1>&2 &&
            return 1
          set -- "$VISUAL"
        else
          set -- "$param"
        fi
        continue
      fi

      case $param in
      -) set -- "$@" - && unset -v _nv_no_input && continue ;;
      -*) set -- "$@" "$param" && continue ;;
      @) param=$(nv n) ;;
      @@*) param="$envy_home${param#@@}" ;;
      esac

      unset -v _nv_no_args
      case $param in
      /* | */ | [[:digit:]]* | *[![:alnum:]_/]* | */*/*)
        set -- "$@" "$param"
        ;;
      *) set -- "$@" "$envy_home/env/$param" ;;
      esac
    done

    [ "$_nv_no_args" ] &&
      case $1 in
      cat | nano | "$VISUAL") set -- "$@" "$envy_home/env/$(nv n)" ;;
      diff)
        unset -v _nv_no_input
        set -- "$@" - "$envy_home/env/$(nv n)"
        ;;
      ls | cd) set -- "$@" "$envy_home/env/" ;;
      esac

    if [ "${edr+.}" ]; then
      echo "${_nv_no_input-"export |"}" "$@"
    elif [ "$_nv_no_input" ]; then
      "$@"
    else
      nv export | "$@"
    fi
    ;;

  # Builtin commands and no argument defaults or actions
  close | close-a | \
    domain | d | domain-a | da | \
    env | e | env-a | ea | env-n | env-p | env-u | \
    export | x | exclude | \
    name | n | name-a | na | \
    open | o | \
    pattern | p | pattern-a | pa | pattern-s | ps | \
    unset | unset-a | unset-d | \
    switch | s | \
    find | f | find-a | fa | \
    profile-open | profile-save | \
    grep | grep-a | grep-s | \
    home | \
    new | \
    which | w | \
    work)

    _nv_cmd=$1

    # look ahead
    shift && case $1 in
    '')
      # commands or options with no argument
      case $_nv_cmd in

      # Working environment

      close | c) nv c-- $(nv d) ;;
      close-a) nv c-- $(nv da) ;;

      domain | d) nv rd-- "$envy_domain" ;;
      domain-a | da)
        set | grep -e '^envy_domain_' | while IFS='=' read -r key _; do
          printf %s\\n "${key#envy_domain_}"
        done
        ;;

      env | e) nv e-- $(nv d) ;;
      env-a | ea) nv e-- $(nv da) ;;

      export | x)
        echo "ENVY_PATTERN=$(nv p)"
        for _nv_name in $(nv g-- "$(nv p)"); do
          if [ "$(printf %s "$(printenv -- "$_nv_name")" | wc -l)" -eq 0 ]; then
            printf '%s=%s\n' "$_nv_name" "$(printenv -- "$_nv_name")"
          else
            printf "%s<<---.,__,.---\\n" "$_nv_name"
            printf %s "$(printenv -- "$_nv_name")" | while IFS= read -r _nv_line || [ "$_nv_line" ]; do
              printf '%s\n' "$_nv_line"
            done
            printf '%s\n' "---.,__,.---"
          fi
        done | grep .
        ;;

      name | n) nv en-- "$envy_domain" ;;
      name-a | na) nv en-- $(nv da) ;;

      new) nv eu-- "$envy_domain" ;;

      pattern | p) nv ep-- "$envy_domain" ;;
      pattern-a | pa) nv ep-- $(nv da) ;;
      pattern-s | ps) printf %s\\n "$envy_shell" ;;

      # Environment File

      find | f) nv f-- "*" ;;
      find-a | fa) nv fa-- "*" ;;

      profile-find) nv profile-find-- "*" ;;
      profile-open) nv profile-open-- "$envy_profile" ;;
      profile-save) nv profile-save-- "$envy_profile" ;;

      # Other Commands

      home) printf %s\\n "$envy_home" ;;

      which | w) nv w-- "$(nv n)" ;;

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

  close-- | c--)
    shift
    nv eu-- "$@"
    for __; do
      unset -v envy_domain_$(nv rd-- "$__")
    done
    if ! nv e-- "$envy_domain" >/dev/null; then
      for __ in $(nv da); do envy_domain=$__ && return 0; done
      nv work-- nv/default >/dev/null
    fi
    ;;

  domain-- | d--) nv e-- "$2" && envy_domain=$(nv rd-- "$2") ;;

  env-- | e--)
    shift && for __; do
      __="$(eval 'echo $envy_domain_'"$(nv rd-- "$__")")" && [ "$__" ] &&
        printf %s\\n "$__"
    done | grep .
    ;;
  env-n-- | en--)
    shift && nv e-- "$@" | while read -r _nv_line; do
      nv rn-- "${_nv_line%%.*}"
    done | grep .
    ;;
  env-p-- | ep--)
    shift && nv e-- "$@" | while IFS= read -r _nv_line; do
      printf %s\\n "${_nv_line#*.}"
    done | grep .
    ;;
  env-u-- | eu--)
    shift && __=$(nv ep-- "$@") && while IFS= read -r _nv_line; do
      unset -v -- $(nv g-- "$_nv_line")
    done <<e8f533c7-482c-49e9-940f-1764f9e214ed
$__
e8f533c7-482c-49e9-940f-1764f9e214ed
    ;;

  # variable name test
  vnt--) printf %s "$2" | grep -E -e "^[_A-Za-z][_A-Za-z0-9]*$" |
    grep -E -e "^($3)" | grep -qvE -e "^($envy_shell)" ;;

  export-- | x--)
    shift && [ $# -gt 0 ] && for __; do
      if nv vnt-- "${__%%=*}" "$(nv p)"; then
        # shellcheck disable=SC2163
        export -- "$__"
      else
        echo "nv: export: ${__%%=*}: bad or excluded variable name" 1>&2
      fi
    done
    ;;

  name-- | n--) nv work-- "$2" "$(nv p)" ;;

  pattern-- | p--) nv work-- "$(nv n)" "$2" ;;

  printenv | pe) shift && nv . printenv "$@" ;;

  rd--)
    # resolve domain, default to working or nv
    nv rt-- "$2" && case $2 in
    */*) echo "name: $2: domain may not have a slash" 1>&2 && return 1 ;;
    '') if [ "$envy_domain" ]; then nv rd-- "$envy_domain"; else echo 'nv'; fi ;;
    *) echo "$2" ;;
    esac
    ;;
  rn--)
    # resolve name, valid, and default to working domain.
    nv rt-- "$2" && case $2 in
    */*) echo "$2" ;;
    '') echo "name: may not be empty" 1>&2 && return 1 ;;
    *) echo "$(nv rd--)/$2" ;;
    esac
    ;;
  rt--)
    # resolve test name.  empty is a valid name to resolve to curren
    case $2 in
    /* | */)
      echo "name: $2: may not have a leading or trailing slash" 1>&2
      return 1
      ;;
    [[:digit:]]*)
      echo "name: $2: may not have a leading digit" 1>&2
      return 1
      ;;
    *[![:alnum:]/_]*)
      echo "name: $2: may only contain alphanumeric, underscore or slash" 1>&2
      return 1
      ;;
    */*/*)
      echo "name: $2: may only have one slash" 1>&2
      return 1
      ;;
    *) return 0 ;;
    esac
    ;;

  new-- | work--)
    # set working environment name and pattern, unset old domain if new--
    if _nv_wrn=$(nv rn-- "$2"); then
      envy_domain=${_nv_wrn%%/*}
      [ "$1" = new-- ] && nv eu-- "$envy_domain"
      eval 'envy_domain_'"$envy_domain"'="$_nv_wrn.${3:-.}"'
      printf '%s\n' "$_nv_wrn.${3:-.}"
    fi
    ;;

  unset-- | u--)
    shift && [ $# -gt 0 ] && for __; do
      nv vnt-- "$__" "$(nv p)" && unset -v -- "$__"
    done
    ;;

  #
  # Environment File Commands
  #

  find-- | f--)
    shift && for __; do
      find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/$(nv d)/$__" |
        while IFS= read -r _nv_line; do
          printf %s\\n "${_nv_line#$envy_home/env/}"
        done
    done | grep .
    ;;
  find-a-- | fa--)
    shift && for __; do
      find "$envy_home/env" -mindepth 2 -maxdepth 2 -type f -path "$envy_home/env/$__" |
        while IFS= read -r _nv_line; do
          printf %s\\n "${_nv_line#$envy_home/env/}"
        done
    done | grep .
    ;;

  open-- | o--)
    shift && [ $# -gt 0 ] && for __; do
      _nv_orn=$(nv rn-- "$__") && nv new-- "$_nv_orn" >/dev/null &&
        nv o- <"$envy_home/env/$_nv_orn"
    done
    ;;

  open- | o-)
    # export variables from input stream
    while IFS= read -r _nv_line || [ "$_nv_line" ]; do
      case $_nv_line in
      \#* | '') continue ;;
      envy_* | _nv*) echo "nvrc: $_nv_line: Ignoring internal envy environment variable" 1>&2 ;;
      ENVY_PATTERN=*) nv p-- "${_nv_line#*=}" ;;
      *=*) nv x-- "$_nv_line" ;;
      *\<\<*)
        unset _nv_value
        _nv_name=${_nv_line%%<<*} _nv_delim=${_nv_line#*<<}
        while IFS= read -r _nv_line || [ "$_nv_line" ]; do
          [ "$_nv_line" = "$_nv_delim" ] && break
          _nv_value="${_nv_value+$_nv_value
}$_nv_line"
        done <&0
        nv x-- "$_nv_name=$_nv_value"
        ;;
      *) echo "nv: open: $_nv_line: line ignored" 1>&2 ;;
      esac
    done <&0
    ;;

  save)
    ! _nv_name=$(nv n) && return 1
    case $_nv_name in */) echo "save: $_nv_name: Must provide an environment name" 1>&2 && return 1 ;; esac

    mkdir -p -- "$envy_home/env/$(nv d)"
    nv x >"$envy_home/env/$_nv_name"
    nv e
    ;;

  which-- | w--)
    shift && for __; do
      __="$envy_home/env/$(nv rn-- "$__")" && [ -f "$__" ] && printf %s\\n "$__"
    done | grep .
    ;;

  #
  # Profile
  #
  profile)
    # handle profile sub commands here, not above, otherwise profile -open would be valid
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
        while IFS= read -r file; do
          printf %s\\n "${file#$envy_home/profile/}"
        done | grep .
    done
    ;;

  #
  # Other Commands
  #

  grep-- | g--) shift && nv ga-- "$@" | grep -vE -e "^($envy_shell)" ;;

  grep-s-- | gs--) shift && nv ga-- "$@" | grep -E -e "^($envy_shell)" ;;

  grep-a-- | ga--) shift &&
    printf '%s\n' "$@" | while read -r _nv_line; do
      awk 'BEGIN{for(v in ENVIRON) print v}' | grep -vE -e 'AWKLIBPATH$|AWKPATH$' |
      grep -E -e "^($_nv_line)"
    done | sort | uniq | grep . ;;

  version) echo "envy version 0.7.1" ;;

  help)
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

usage:  nv OPTION... [NAME=VALUE]... [COMMAND [ARG]...]
        nv NAME=VALUE...
        nv NAME...
        nv SUBCOMMAND
        
Show and manage program envionment variables.  Envy differs from
env, export, printenv and unset in that it does not by default show 
shell environment variables like TERM, HOME, PATH.

Examples of program environment variables are GIT_* for git, AWS_* 
for aws-cli, and so on.

Options
/             All open environment variables
.             Working environment variables
%             Shell environment variables
@             Working environment file variables.

Working Environment Commands
   close     Close environment
d, domain    Print the working environment domain name
e, env       Print the working environment name and grep pattern
x, export    Set the export attribute for working environment variables
   na        Print active environment names
n, name      Print curent domain full name
p, pattern   Print or set the working environment variable name pattern
   printenv  Print all or part of the working environment
s, switch    Switch working environment to a new domain
   work      Set working environment for a name and pattern
   unset     Unset a working environment variable

Environment File Management Commands
-           Open from stdin
   edit     Edit an environment file using ${VISUAL-** VISUAL environment variable not set **)}
f, find     Find all environment files
o, open     Open a new working environment from file
   save     Save or replace the working environment
w, which    Print full file path to saved environment

Enhanced Linux File Managed Commands
cat | cd | cp | diff | ls | mkdir | mv | rm

Profile File Commands
 profile-find  Find a profile file
 profile-open  Open profile environments 
 profile-save  Save or replace profile with environment names

Other Commands
   grep        Grep all envy variable names
   help        Show this help
   home        Show home directory for envy and profile files
   version     Print the version information
EOF
    ;;
  help-close | close-h)
    cat <<'___'
usage:  nv close [DOMAIN]...

Unset all the variables in the domain and close the domain.  If no
domainn specified, then the working domain is closed. 
___
    ;;

  help-domain | help-d | domain-h | d-h)
    cat <<'___'
usage:  nv domain [OPTION] [DOMAIN]...

Print the working environment domain name.

Options
-a  Print all open environment domain names
___
    ;;

  help-env | help-e | env-h | e-h)
    cat <<'___'
usage:  nv env [OPTION] [DOMAIN]...

Print the working environment name and grep pattern.

Options
-a  Print all open environment names and grep patterns.
-n  Print just the environment name
-p  Print just the environment pattern
___
    ;;

  help-export | help-x | export-h | x-h)
    cat <<'eof'
usage:  nv export name[=word]...

Set the export attribute for a working environment variable

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

  help-grep | grep-h)
    cat <<'___'
usage:  nv grep [ -s | -a ] PATTERN

Grep envy environment variable names.

Options
-s  Grep shell environment variable names.
-a  Grep any environment variable names.
___
    ;;
  help-name | help-n | name-h | n-h) echo "usage: name -afh" ;;
  help-open | open-h)
    cat <<'___'
usage:  nv open NAME...

Open an environment into a clean domain.  All the previous domain environment variables are unset.
___
    ;;
  help-pattern | help-p | pattern-h | p-h) echo "usage: name -achu" ;;
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
  help-save | save-h)
    cat <<'___'
usage:  nv save

Save the working environment.  This is a shortcut for nv export > $(nv home)/env/$(nv name)
___
    ;;
  help-unset | unset-h)
    cat <<'___'
usage:  nv unset [-a | -h] NAME...

Unset values and attributes of variables in the working environment.

Options
-a  unset variable in any environment
-h  help

Description

Each variable specified by name shall be unset.

Unsetting a variable or function that was not previously set
shall not be considered an error and does not cause the shell to
abort.
___
    ;;

  help-which | help-w | which-h | w-h)
    cat <<'___'
usage:  nv which [NAME...]

Print the envy file location.  This is equivalent to $(nv home)/envy/NAME.

If no NAME provided, the file location of the working environment is provided.
___
    ;;

  # native file commands with name expansion
  help-cat | help-cd | help-cp | help-diff | help-ls | help-mkdir | help-mv | help-rm)
    cat <<'___'
usage:  nv cat | cd | cp | diff | ls | mkdir | mv | rm  [FILE]...

Execute normal linux file based command with environment name expansion to its file
location.

For the working environment file, use @ to signify the file.

If no file is provided, the following defaults are used:

cat @
cd @@
diff - @
ls @@

___
    ;;

  *)
    if printf %s "$1" | grep -qE -e '^([[:upper:]]|_)([[:alpha:]]|_|[[:digit:]])*$'; then
      nv . printenv "$@"
    else
      echo "nv: $(printf '%s ' "$@"): Unknown resource or command" 1>&2 && nv help 1>&2 && return 1
    fi
    ;;
  esac
}

#
# Initailize envy
#

if readonly envy_home="${ENVY_HOME-$HOME/.config/envy}" 2>/dev/null; then
  [ -f "$envy_home/.nvrc" ] &&
    # load extension to shell environment
    exec 3<"$envy_home/.nvrc" &&
    while IFS= read -r _nv_line || [ "$_nv_line" ]; do
      case $_nv_line in
      '' | \#*) continue ;;
      envy_* | _nv*) echo "nvrc: $_nv_line: Ignoring internal envy environment variable" 1>&2 ;;
      *=*)
        _nv_name="${_nv_line%%=*}" _nv_value="${_nv_line#*=}"
        ;;
      *\<\<*)
        unset _nv_value
        _nv_name=${_nv_line%%<<*} _nv_delim=${_nv_line#*<<}
        while IFS= read -r _nv_line || [ "$_nv_line" ]; do
          [ "$_nv_line" = "$_nv_delim" ] && break
          _nv_value="${_nv_value+$_nv_value
}$_nv_line"
        done <&3
        ;;
      *) echo "nvrc: $_nv_line: Ignoring invalid nvrc statement" 1>&2 ;;
      esac

      # export and process within here-doc for expansions
      export -- "$_nv_name=$(
        eval 'cat <<ff483722-a9e5-4438-8b00-28ae9f416136
'"$_nv_value"'
ff483722-a9e5-4438-8b00-28ae9f416136'
      )"
    done <&3

  # ENVY_SHELL, ENVY_PROFILE could be set in .nvrc
  readonly envy_shell="${ENVY_SHELL-COLOR|COMMAND_|EDITOR$|ENVY_|HOSTNAME$|HOSTTYPE$|HOME$|LANG$|LaunchInstanceID$|LC_|LOGNAME$|LS_|ITERM_|NAME$|OLDPWD$|PATH$|PWD$|SECURITYSESSIONID$|SHELL$|SHLVL$|SSH_|TERM$|TERM_|TMPDIR$|VSCODE_|USER|VISUAL$|WSLENV$|WSL_|XDG_|XPC_|_$|__${ENVY_SHELL_EXTRA:+|$ENVY_SHELL_EXTRA}}"

  envy_profile="${ENVY_PROFILE-nv}"
  if [ -f "$envy_home/profile/$envy_profile" ]; then
    nv profile-open-- "$envy_profile"
  elif [ -f "$envy_home/env/nv/default" ]; then
    nv o-- nv/default
  else
    nv work-- nv/default
  fi

  # ensure directories
  mkdir -p -- "$envy_home/env/nv"
  mkdir -p -- "$envy_home/profile"
fi

#
# must source to use nv: . envy.sh | source envy.sh
#
