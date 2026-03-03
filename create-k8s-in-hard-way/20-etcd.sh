#!/bin/sh

if [ ! -r ./etcd-v3.6.8-linux-amd64.tar.gz ]; then
	wget https://github.com/etcd-io/etcd/releases/download/v3.6.8/etcd-v3.6.8-linux-amd64.tar.gz
fi

tar -xzvf etcd-v3.6.8-linux-amd64.tar.gz -C /k8s/

mkdir -p /var/lib/etcd


cat <<EOF
/k8s/etcd-v3.6.8-linux-amd64/etcd --name master-1 \
  --cert-file=/k8s/pki/ca.crt \
  --key-file=/k8s/pki/ca.key \
  --peer-cert-file=/k8s/pki/ca.crt \
  --peer-key-file=/k8s/pki/ca.key \
  --trusted-ca-file=/k8s/pki/ca.crt \
  --peer-trusted-ca-file=/k8s/pki/ca.crt \
  --initial-advertise-peer-urls https://172.16.0.50:2380 \
  --listen-peer-urls https://172.16.0.50:2380 \
  --listen-client-urls https://172.16.0.50:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://172.16.0.50:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster master-1=https://172.16.0.50:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
EOF


cat <<EOF
/k8s/etcd-v3.6.8-linux-amd64/etcd --name master-1 \
  --cert-file=/k8s/pki/etcd.crt \
  --key-file=/k8s/pki/etcd.key \
  --peer-cert-file=/k8s/pki/etcd.crt \
  --peer-key-file=/k8s/pki/etcd.key \
  --trusted-ca-file=/k8s/pki/ca.crt \
  --peer-trusted-ca-file=/k8s/pki/ca.crt \
  --client-cert-auth=true \
  --peer-client-cert-auth=true \
  --initial-advertise-peer-urls https://172.16.0.50:2380 \
  --listen-peer-urls https://172.16.0.50:2380 \
  --listen-client-urls https://172.16.0.50:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://172.16.0.50:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster master-1=https://172.16.0.50:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
EOF