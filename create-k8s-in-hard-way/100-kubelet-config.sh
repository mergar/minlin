#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Поздравляю! Вы успешно запустили
#Control Plane полностью вручную. Это самая сложная часть «Hard Way».
#Теперь переходим к Worker-нодам. Для каждой из трех нод (172.16.0.51, 172.16.0.52, 172.16.0.53) конфигурация kubelet будет почти идентичной, за исключением одного важного поля — podCIDR (подсеть для контейнеров на конкретной ноде), чтобы IP-адреса подов не пересекались.

#1. Содержимое kubelet-config.yaml
#Создайте этот файл на каждой ноде (рекомендуемый путь: /k8s/pki/kubelet-config.yaml).
#Важно: Для worker-1 укажите podCIDR: "10.200.1.0/24", для worker-2 — 10.200.2.0/24, для worker-3 — 10.200.3.0/24.

cat >/k8s/pki/kubelet-config-1.yaml<<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/k8s/pki/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.1.0/24"
runtimeRequestTimeout: "15m"
tlsCertFile: "/k8s/pki/worker-1.crt"
tlsPrivateKeyFile: "/k8s/pki/worker-1.key"
EOF

cat >/k8s/pki/kubelet-config-2.yaml<<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/k8s/pki/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.2.0/24"
runtimeRequestTimeout: "15m"
tlsCertFile: "/k8s/pki/worker-2.crt"
tlsPrivateKeyFile: "/k8s/pki/worker-2.key"
EOF

cat >/k8s/pki/kubelet-config-3.yaml<<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/k8s/pki/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.3.0/24"
runtimeRequestTimeout: "15m"
tlsCertFile: "/k8s/pki/worker-3.crt"
tlsPrivateKeyFile: "/k8s/pki/worker-3.key"
EOF

