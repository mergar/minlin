#!/bin/sh
#3. Дополнительные зависимости (CRI и CNI)
#Kubernetes сам по себе не умеет запускать контейнеры. На воркеры нужно поставить Container Runtime. Самый надежный выбор для Debian — containerd.
#Также скачайте CNI Plugins (сетевые интерфейсы), без которых поды не получат IP-адреса:

if [ ! -r ./cni-plugins-linux-amd64-v1.9.0.tgz ]; then
	wget https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-amd64-v1.9.0.tgz
fi
mkdir -p /k8s/opt/cni/bin
tar -xzvf cni-plugins-linux-amd64-v1.9.0.tgz -C /k8s/opt/cni/bin/

