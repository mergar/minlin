#!/bin/sh
export PATH=/k8s:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd /k8s/create-k8s-in-hard-way/pki

#1. Переменная окружения Master IP
#Выполните на рабочей машине, где лежат сертификаты:
KUBERNETES_PUBLIC_ADDRESS=172.16.0.50

#2. Генерация Kubeconfig
#Используем kubectl для упаковки сертификатов в конфиги. Мы выставляем флаг --embed-certs=true, чтобы файлы были переносимыми.
#Для Worker-нод (выполнить в цикле):

for instance in worker-1 worker-2 worker-3; do
  kubectl config set-cluster kubernetes-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.crt \
    --client-key=${instance}.key \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

#Для системных служб и Admin:
#Повторите логику для kube-proxy, kube-controller-manager, kube-scheduler и admin. Вот пример для kube-proxy:

for i in kube-proxy kube-controller-manager kube-scheduler admin; do
	kubectl config set-cluster kubernetes-hard-way --certificate-authority=ca.crt --embed-certs=true --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 --kubeconfig=${i}.kubeconfig
	kubectl config set-credentials system:${i} --client-certificate=${i}.crt --client-key=${i}.key --embed-certs=true --kubeconfig=${i}.kubeconfig
	kubectl config set-context default --cluster=kubernetes-hard-way --user=system:${i} --kubeconfig=${i}.kubeconfig
	kubectl config use-context default --kubeconfig=${i}.kubeconfig
done
