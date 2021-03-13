# Bash Cheat Sheet

## Subshells

echo in subshell does not go to terminal prompt in subshell

## read

### Reading line

### Prompt

read -p is not posix

```sh
echo "Prompt: "
read x

```


## Variable Gotchas

### grep

```sh
grep -e "$x"

# this will not grep for -E as a pattern
x="-E" && printf %s "$x" | grep "$x"

# this will
x="-E" && printf %s "$x" | grep -e "$x"
```

### echo

Echo is fine for printing human readable messages.  For returning values, unless it is know the value cannot be "-n", use

```sh
# quotes are required around variable
printf %s\\n "$v"

# without quotes
x="one two" && printf "%s\\n" $x
```

## return 0

Return 0 should be looked at closely, usually can allow last exit status to return.  return $? does not work after a test [].

Return 0 is sometimes needed if last statement is a loop as loop exits with -1:

```sh
f() {
  for __ in $var; do
  done;
  # needed here
  return 0
}
```

### nesting
To avoid use of return, nesting is more common:
```sh
if g -l | cat -n; then
  echo "Repo number(s): "
  if read lines; then
    for __ in lines; do
      [ "$__" -eq "$__" ] 2>/dev/null &&
        printf %s\\n "$(g -l | sed $__'!d')"
      return 0
    done
  fi
fi
```


## Function Variables

Variables in posix are not local, use globally unique names


## Spaces

Spaces required [ "$1" ], spaces may not be used, x="one"  x = "one"


## Style

! [ "$2" ] vs [ ! "$2" ] 
