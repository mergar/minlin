#!/bin/sh
# Определяем версию (например, v1.35.1)
K8S_VERSION="v1.35.1"

if [ ! -r ./containerd-2.2.1-linux-amd64.tar.gz ]; then
	# Скачиваем компоненты мастера
wget --show-progress --https-only --timestamping \
    "https://github.com/containerd/containerd/releases/download/v2.2.1/containerd-2.2.1-linux-amd64.tar.gz"
fi


tar -xzvf containerd-2.2.1-linux-amd64.tar.gz -C /k8s/
