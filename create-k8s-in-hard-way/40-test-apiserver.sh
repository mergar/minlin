#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
kubectl get componentstatuses --kubeconfig=/k8s/pki/admin.kubeconfig


# пример вывода:
#Warning: v1 ComponentStatus is deprecated in v1.19+
#NAME                 STATUS      MESSAGE                                                                                        ERROR
#controller-manager   Unhealthy   Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused   
#scheduler            Unhealthy   Get "https://127.0.0.1:10259/healthz": dial tcp 127.0.0.1:10259: connect: connection refused   
#etcd-0               Healthy     ok

#Про Warning:
#ComponentStatus действительно устарел, в будущем его заменят на проверки через /healthz, но для «Hard Way» в ручном режиме это всё еще самый быстрый способ понять, что база данных подключена.
