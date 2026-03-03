#!/bin/sh

#2. Запуск kube-apiserver (на Master)
#Это основной компонент. Он должен видеть и etcd, и все ваши сертификаты.
/k8s/kube-apiserver \
  --advertise-address=172.16.0.50 \
  --allow-privileged=true \
  --authorization-mode=Node,RBAC \
  --client-ca-file=/k8s/pki/ca.crt \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-cafile=/k8s/pki/ca.crt \
  --etcd-certfile=/k8s/pki/ca.crt \
  --etcd-keyfile=/k8s/pki/ca.key \
  --etcd-servers=https://172.16.0.50:2379 \
  --kubelet-certificate-authority=/k8s/pki/ca.crt \
  --kubelet-client-certificate=/k8s/pki/kube-apiserver.crt \
  --kubelet-client-key=/k8s/pki/kube-apiserver.key \
  --service-account-key-file=/k8s/pki/service-account.pub \
  --service-account-signing-key-file=/k8s/pki/service-account.key \
  --service-account-issuer=https://kubernetes.default.svc.cluster.local \
  --service-cluster-ip-range=10.32.0.0/24 \
  --tls-cert-file=/k8s/pki/kube-apiserver.crt \
  --tls-private-key-file=/k8s/pki/kube-apiserver.key \
  --v=2
