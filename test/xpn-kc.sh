#!/bin/sh

. shert.sh

## cheat sheet - https://kubernetes.io/docs/reference/kubectl/cheatsheet/
assert_equals "'kubectl' 'config' 'view'" "$(dr='' ./kc co v)"

assert_equals "'kubectl' 'config' 'view' '"'-o=jsonpath={.users[?(@.name == "e2e")].user.password}'"'" \
  "$(dr='' ./kc co v --ojp '{.users[?(@.name == "e2e")].user.password}')"

assert_equals "'kubectl' 'config' 'get-contexts'" \
  "$(dr='' ./kc co g)"
assert_equals "'kubectl' 'config' 'current-context'" \
  "$(dr='' ./kc co c)"
assert_equals "'kubectl' 'config' 'use-context' 'docker-desktop'" \
  "$(dr='' ./kc co u docker-desktop)"

assert_equals "'kubectl' 'config' 'set-credentials' 'kubeuser/foo.kubernetes.com' '--username=kubeuser' '--password=kubepassword'" \
  "$(dr='' ./kc co scr kubeuser/foo.kubernetes.com -u kubeuser -p kubepassword)"
assert_equals "'kubectl' 'config' 'set-context' '--current' '--namespace' 'ggckad-s2'" \
  "$(dr='' ./kc scns ggckad-s2)"

assert_equals "'kubectl' 'apply' '-f' './my-manifest.yaml'" \
  "$(dr='' ./kc af ./my-manifest.yaml)"
assert_equals "'kubectl' 'create' 'deploy' 'nginx' '--image=nginx'" \
  "$(dr='' ./kc cd nginx --image=nginx)"
assert_equals "'kubectl' 'create' 'deploy' 'nginx' '--image=nginx'" \
  "$(dr='' ./kc create d nginx --image=nginx)"
assert_equals "'kubectl' 'create' 'deploy' 'nginx' '--image=nginx'" \
  "$(dr='' ./kc c d nginx --image=nginx)"
assert_equals "'kubectl' 'explain' 'po'" \
  "$(dr='' ./kc ep)"

# Viewing, finding resources

# Get commands with basic output
assert_equals "'kubectl' 'get' 'svc'" \
  "$(dr='' ./kc gs)"
assert_equals "'kubectl' 'get' 'po' '--all-namespaces'" \
  "$(dr='' ./kc gp --all)"
assert_equals "'kubectl' 'get' 'po' '-o=wide'" \
  "$(dr='' ./kc gp --ow)"
assert_equals "'kubectl' 'get' 'deploy' 'my-dep'" \
  "$(dr='' ./kc gd my-dep)"
assert_equals "'kubectl' 'get' 'po'" \
  "$(dr='' ./kc gp)"
assert_equals "'kubectl' 'get' 'po' 'my-pod' '-o=yaml'" \
  "$(dr='' ./kc gp my-pod -y)"

assert_equals "'kubectl' 'get' 'po' 'my-pod' '-o=yaml'" \
  "$(dr='' ./kc g po my-pod -y)"

# Describe commands with verobose output
assert_equals "'kubectl' 'describe' 'no' 'my-node'" \
  "$(dr='' ./kc d no my-node)"
assert_equals "'kubectl' 'describe' 'po' 'my-node'" \
  "$(dr='' ./kc d p my-node)"

# List Services Sorted by Name
assert_equals "'kubectl' 'get' 'svc' '--sort-by=.metadata.name' '-o=yaml'" \
  "$(dr='' ./kc gs -sy)"


assert_equals "'kubectl' 'get' 'po' '--field-selector=status.phase=Running'" \
  "$(dr='' ./kc gp --fs status.phase=Running)"
