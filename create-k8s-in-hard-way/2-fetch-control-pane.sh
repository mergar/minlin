#!/bin/sh
# Определяем версию (например, v1.35.1)
K8S_VERSION="v1.35.1"

if [ ! -r ./kubectl ]; then
	# Скачиваем компоненты мастера
wget --show-progress --https-only --timestamping \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kube-apiserver" \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kube-controller-manager" \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kube-scheduler" \
  "https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kubectl"
fi

# Установка
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
cp -a kube-apiserver kube-controller-manager kube-scheduler kubectl /k8s/

