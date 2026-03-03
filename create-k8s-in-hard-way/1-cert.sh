#!/bin/sh
rm -rf pki
mkdir -p pki && cd pki
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=KUBERNETES-CA" -days 3650 -out ca.crt

openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr

openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 365


#4. Сертификат API-сервера (Самый важный)
#Здесь начинаются тонкости. API-сервер должен откликаться по нескольким именам и IP (localhost, IP мастера, IP внутреннего сервиса).
#
#    Создайте файл конфигурации openssl-apiserver.cnf:
#    Замените 192.168.1.10 на реальный IP вашего Debian-сервера.

cat >openssl-apiserver.cnf<<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 172.16.0.50
IP.3 = 10.32.0.1
EOF

## (Примечание: 10.32.0.1 — это стандартный первый IP из Service Cluster IP range).

openssl genrsa -out kube-apiserver.key 2048
openssl req -new -key kube-apiserver.key -config openssl-apiserver.cnf -subj "/CN=kube-apiserver" -out kube-apiserver.csr
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-apiserver.crt -extensions v3_req -extfile openssl-apiserver.cnf -days 365

# 5. Ключи для Service Accounts
# Для подписи Service Account токенов контроллер-менеджеру нужна просто пара ключей (API-сервер использует публичный для проверки, менеджер приватный для подписи).
openssl genrsa -out service-account.key 2048
openssl rsa -in service-account.key -pubout -out service-account.pub


#Для трех воркер-нод в Kubernetes крайне важно соблюсти правило именования в сертификатах, чтобы работал
#Node Authorizer (встроенная система безопасности). Имя пользователя в сертификате (CN) должно быть строго system:node:<hostname>, а организация (O) — system:nodes.
#Допустим, ваши ноды называются: worker-1, worker-2, worker-3.

#1. Подготовка конфигурационного файла (worker-openssl.cnf)
#Поскольку каждому воркеру нужны SAN (Subject Alternative Names), создадим базовый конфиг. Создайте файл worker.cnf:
cat >worker.cnf<<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = HOSTNAME_PLACEHOLDER
IP.1 = IP_PLACEHOLDER
EOF


#2. Цикл генерации для каждой ноды
#Вам нужно выполнить эти команды для каждой ноды, подставляя их данные.

#Для worker-1 (пример):

# 1. Генерируем ключ
openssl genrsa -out worker-1.key 2048

# 2. Создаем временный конфиг для этой ноды
sed "s/HOSTNAME_PLACEHOLDER/worker-1/g; s/IP_PLACEHOLDER/172.16.0.51/g" worker.cnf > worker-1.cnf

# 3. Создаем запрос (CSR)
# ВАЖНО: CN=system:node:worker-1 и O=system:nodes
openssl req -new -key worker-1.key \
  -config worker-1.cnf \
  -subj "/CN=system:node:worker-1/O=system:nodes" \
  -out worker-1.csr

# 4. Подписываем сертификат нашим CA
openssl x509 -req -in worker-1.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out worker-1.crt -extensions v3_req -extfile worker-1.cnf -days 365

###
#Для worker-2 (пример):

# 1. Генерируем ключ
openssl genrsa -out worker-2.key 2048

# 2. Создаем временный конфиг для этой ноды
sed "s/HOSTNAME_PLACEHOLDER/worker-2/g; s/IP_PLACEHOLDER/172.16.0.52/g" worker.cnf > worker-2.cnf

# 3. Создаем запрос (CSR)
# ВАЖНО: CN=system:node:worker-2 и O=system:nodes
openssl req -new -key worker-2.key \
  -config worker-2.cnf \
  -subj "/CN=system:node:worker-2/O=system:nodes" \
  -out worker-2.csr

# 4. Подписываем сертификат нашим CA
openssl x509 -req -in worker-2.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out worker-2.crt -extensions v3_req -extfile worker-2.cnf -days 365


#Для worker-3 (пример):

# 1. Генерируем ключ
openssl genrsa -out worker-3.key 2048

# 2. Создаем временный конфиг для этой ноды
sed "s/HOSTNAME_PLACEHOLDER/worker-3/g; s/IP_PLACEHOLDER/172.16.0.53/g" worker.cnf > worker-3.cnf

# 3. Создаем запрос (CSR)
# ВАЖНО: CN=system:node:worker-3 и O=system:nodes
openssl req -new -key worker-3.key \
  -config worker-3.cnf \
  -subj "/CN=system:node:worker-3/O=system:nodes" \
  -out worker-3.csr

# 4. Подписываем сертификат нашим CA
openssl x509 -req -in worker-3.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out worker-3.crt -extensions v3_req -extfile worker-3.cnf -days 365


#3. Остальные системные компоненты
#Для работы кластера нам осталось сгенерировать сертификаты для контроллеров, планировщика и прокси. Здесь SAN не требуются, достаточно простых команд:

#    Kube-Proxy (CN=system:kube-proxy):
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-proxy.crt -days 365


# Controller Manager (CN=system:kube-controller-manager):
openssl genrsa -out kube-controller-manager.key 2048
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 365

# Scheduler (CN=system:kube-scheduler):
openssl genrsa -out kube-scheduler.key 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-scheduler.crt -days 365


# Итог по файлам
#У вас в папке pki должен быть внушительный список .crt и .key файлов.
#Следующий логический шаг: Генерация kubeconfig файлов на основе этих сертификатов. Это файлы, которые позволят компонентам (kubelet, scheduler и т.д.) «понимать», куда подключаться и какие сертификаты использовать.
