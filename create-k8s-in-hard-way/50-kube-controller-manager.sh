#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

/k8s/kube-controller-manager \
  --bind-address=0.0.0.0 \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/k8s/pki/ca.crt \
  --cluster-signing-key-file=/k8s/pki/ca.key \
  --kubeconfig=/k8s/pki/kube-controller-manager.kubeconfig \
  --leader-elect=false \
  --root-ca-file=/k8s/pki/ca.crt \
  --service-account-private-key-file=/k8s/pki/service-account.key \
  --service-cluster-ip-range=10.32.0.0/24 \
  --use-service-account-credentials=true \
  --v=2

# Примечание: --leader-elect=false используем, так как у нас сейчас всего один мастер.
