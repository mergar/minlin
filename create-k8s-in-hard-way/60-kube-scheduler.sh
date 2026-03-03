#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

/k8s/kube-scheduler \
  --kubeconfig=/k8s/pki/kube-scheduler.kubeconfig \
  --leader-elect=false \
  --v=2

# Примечание: --leader-elect=false используем, так как у нас сейчас всего один мастер.