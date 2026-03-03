#!/bin/sh
# Определяем версию (например, v1.35.1)
K8S_VERSION="v1.35.1"

if [ ! -r ./kube-proxy ]; then
	# Скачиваем компоненты мастера
wget --show-progress --https-only --timestamping \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kube-proxy" \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kubelet"

fi

# Установка
chmod +x kube-proxy kubelet
cp -a kube-proxy kubelet /k8s/

