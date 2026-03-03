#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

/k8s/kubelet \
  --config=/k8s/pki/kubelet-config-2.yaml \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --kubeconfig=/k8s/pki/worker-2.kubeconfig \
  --hostname-override=worker-2 \
  --v=2
