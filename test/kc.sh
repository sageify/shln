assert_equals() {
  ! [ "$1" = "$2" ] &&
    printf "assert: '%s': found: '%s'%s\n" "$1" "$2" "${3+": $3"}" &&
    return 1
}

## cheat sheet - https://kubernetes.io/docs/reference/kubectl/cheatsheet/
assert_equals 'kubectl config view' "$(dr= ./kc co v)"

assert_equals 'kubectl config view '"'"'-o=jsonpath={.users[?(@.name == "e2e")].user.password}'"'" \
  "$(dr= ./kc co v -ojp '{.users[?(@.name == "e2e")].user.password}')"

assert_equals 'kubectl config get-contexts' \
  "$(dr= ./kc co g)"
assert_equals 'kubectl config current-context' \
  "$(dr= ./kc co c)"
assert_equals 'kubectl config use-context docker-desktop' \
  "$(dr= ./kc co u docker-desktop)"

assert_equals 'kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword' \
  "$(dr= ./kc co scr kubeuser/foo.kubernetes.com -u kubeuser -p kubepassword)"
assert_equals 'kubectl config set-context --current --namespace ggckad-s2' \
  "$(dr= ./kc scns ggckad-s2)"

assert_equals 'kubectl apply -f ./my-manifest.yaml' \
  "$(dr= ./kc af ./my-manifest.yaml)"
assert_equals 'kubectl create deploy nginx --image=nginx' \
  "$(dr= ./kc cd nginx --image=nginx)"
assert_equals 'kubectl create deploy nginx --image=nginx' \
  "$(dr= ./kc create d nginx --image=nginx)"
assert_equals 'kubectl create deploy nginx --image=nginx' \
  "$(dr= ./kc c d nginx --image=nginx)"
assert_equals 'kubectl explain po' \
  "$(dr= ./kc ep)"

# Get commands with basic output
assert_equals 'kubectl get svc' \
  "$(dr= ./kc gs)"
assert_equals 'kubectl get po --all-namespaces' \
  "$(dr= ./kc gp -all)"
assert_equals 'kubectl get po -o=wide' \
  "$(dr= ./kc gp -ow)"
assert_equals 'kubectl get deploy my-dep' \
  "$(dr= ./kc gd my-dep)"
assert_equals 'kubectl get po' \
  "$(dr= ./kc gp)"
assert_equals 'kubectl get po my-pod -o=yaml' \
  "$(dr= ./kc gp my-pod -oy)"

# Describe commands with verobose output
assert_equals 'kubectl describe no my-node' \
  "$(dr= ./kc d no my-node)"
assert_equals 'kubectl describe po my-node' \
  "$(dr= ./kc d p my-node)"

assert_equals 'kubectl get po --field-selector=status.phase=Running' \
  "$(dr= ./kc gp -fs status.phase=Running)"


assert_equals "kubectl get" "$(dr= ./kc g)"
assert_equals "kubectl -n bogus" "$(dr= ./kc -n bogus)"
assert_equals "kubectl -n bogus get" "$(dr= ./kc -n bogus get)"
assert_equals "kubectl -n g get" "$(dr= ./kc -n g g)"
assert_equals "kubectl --namespace g get" "$(dr= ./kc --namespace g g)"
assert_equals "kubectl -n bogus get" "$(dr= ./kc -n bogus g)"
assert_equals "kubectl -n=kube-system get po" "$(dr= ./kc -nks g p)"
assert_equals "kubectl -n=kube-system get po -o=wide --show-labels" "$(dr= ./kc -nks g p -ow -sl)"
assert_equals "kubectl run debug --rm -i -t --image=busybox --restart=Never" "$(dr= ./kc debug)"

# alias kbeks="aws eks update-kubeconfig --name "
# alias kube="cd ~/.kube"
# alias kb="kubectl"
# alias kbp="kb get po"
# alias kbs="kb get svc"
# alias kbd="kb get deployment "
# alias kbl="kb logs "
# alias kbdel="kb delete po "
# alias kbdeld="kb delete deployment "
# alias kbdels="kb delete svc "
# alias kbdesc="kb describe po "
# alias kbrb="kubectl run -i --rm --tty debug --image=busybox --restart=Never -- sh"
