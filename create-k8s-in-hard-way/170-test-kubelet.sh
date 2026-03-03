#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

kubectl get nodes --kubeconfig=/k8s/pki/admin.kubeconfig
