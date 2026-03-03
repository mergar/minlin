#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Создаем простой под nginx
kubectl run nginx --image=nginx --kubeconfig=/k8s/pki/admin.kubeconfig

# Проверяем статус (он должен перейти в Running)
kubectl get pods -o wide --kubeconfig=/k8s/pki/admin.kubeconfig

echo
echo "test"
echo "kubectl get pods -o wide --kubeconfig=/k8s/pki/admin.kubeconfig"


echo
echo "DEBUG"
echo "kubectl describe pod nginx --kubeconfig=/k8s/pki/admin.kubeconfig"


echo
echo "чтобы удалить:"
echo "kubectl delete pod nginx --kubeconfig=/k8s/pki/admin.kubeconfig --force"



echo "exec"
echo "kubectl exec -it nginx --kubeconfig=/k8s/pki/admin.kubeconfig -- nginx -v"
echo 
echo "Если"
echo "error: Internal error occurred: unable to upgrade connection: Forbidden (user=kube-apiserver, verb=create, resource=nodes, subresource(s)=[proxy])"
echo "то RBAC"

echo "логи пода"
echo "kubectl logs nginx --kubeconfig=/k8s/pki/admin.kubeconfig"
