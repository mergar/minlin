#!/bin/sh

#3. DNS (CoreDNS)
#Без этого шага ваши сервисы не смогут обращаться друг к другу по именам (например, mysql.default.svc.cluster.local).
#Обычно CoreDNS устанавливается как манифест:

#    Скачайте CoreDNS манифест для Kubernetes.
#    Замените $cluster_dns на 10.32.0.10 (как в вашем kubelet-config).
#    Примените: kubectl apply -f coredns.yaml.

#1. Подготовка манифеста
#CoreDNS в ручном режиме развертывается как Deployment и Service с фиксированным IP 10.32.0.10 (который мы ранее прописали в kubelet-config).
#Создайте файл coredns.yaml на мастере:

cat >coredns.yaml<<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
  - apiGroups: [""]
    resources: ["endpoints", "services", "pods", "namespaces"]
    verbs: ["list", "watch"]
  - apiGroups: ["discovery.k8s.io"]
    resources: ["endpointslices"]
    verbs: ["list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
  - kind: ServiceAccount
    name: coredns
    namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
spec:
  replicas: 2
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      serviceAccountName: coredns
      containers:
      - name: coredns
        image: coredns/coredns:1.11.1
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.32.0.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
EOF

kubectl apply -f coredns.yaml --kubeconfig=/k8s/pki/admin.kubeconfig

echo "3. Проверка"
echo "Подождите около минуты, пока образы скачаются и поды запустятся:"
echo
echo "проверка DNS"
echo "kubectl get pods -n kube-system --kubeconfig=/k8s/pki/admin.kubeconfig"


cat <<EOF
Чтобы убедиться, что DNS работает, выполните nslookup из вашего пода nginx:
bash

kubectl exec -it nginx --kubeconfig=/k8s/pki/admin.kubeconfig -- nslookup kubernetes.default

Use code with caution.
Если в ответ придет IP 10.32.0.1 — поздравляю, ваш кластер полностью функционален.
EOF
