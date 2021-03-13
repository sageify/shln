assertEquals() {
  ! [ "$1" = "$2" ] &&
    printf "assert: '%s': found: '%s'%s\n" "$1" "$2" "${3+": $3"}" &&
    return 1
}

## cheat sheet
assertEquals 'kubectl config view' "$(dr= kc co v)"
assertEquals 'kubectl config view -o '"'"'jsonpath={.users[?(@.name == "e2e")].user.password}'"'" \
  "$(dr= kc co v -ojp='{.users[?(@.name == "e2e")].user.password}')"
assertEquals 'kubectl config get-contexts' \
  "$(dr= kc co g)"
assertEquals 'kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword' \
  "$(dr= kc co scr kubeuser/foo.kubernetes.com -u=kubeuser -p=kubepassword)"
assertEquals 'kubectl config set-context --current --namespace=ggckad-s2' \
  "$(dr= kc co sco --current --namespace=ggckad-s2)"
assertEquals 'kubectl apply -f ./my-manifest.yaml' \
  "$(dr= kc af ./my-manifest.yaml)"
assertEquals 'kubectl create deploy nginx --image=nginx' \
  "$(dr= kc c d nginx --image=nginx)"
assertEquals 'kubectl explain po' \
  "$(dr= kc e p)"
assertEquals 'kubectl get svc' \
  "$(dr= kc gs)"
assertEquals 'kubectl get po --all-namespaces' \
  "$(dr= kc gp -all)"
assertEquals 'kubectl get po -o=wide' \
  "$(dr= kc gp -ow)"
assertEquals 'kubectl describe no my-node' \
  "$(dr= kc d no my-node)"
assertEquals 'kubectl get po --field-selector=status.phase=Running' \
  "$(dr= kc gp -fs=status.phase=Running)"


assertEquals "kubectl get" "$(dr= kc g)"
assertEquals "kubectl -n bogus" "$(dr= kc -n bogus)"
assertEquals "kubectl -n bogus get" "$(dr= kc -n bogus get)"
assertEquals "kubectl -n g get" "$(dr= kc -n g g)"
assertEquals "kubectl --namespace g get" "$(dr= kc --namespace g g)"
assertEquals "kubectl -n bogus get" "$(dr= kc -n bogus g)"
assertEquals "kubectl -n=kube-system get po" "$(dr= kc -nks g p)"
assertEquals "kubectl -n=kube-system get po -o=wide --show-labels" "$(dr= kc -nks g p -ow -sl)"
assertEquals "kubectl run debug --rm -i -t --image=busybox --restart=Never" "$(dr= kc debug)"

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
