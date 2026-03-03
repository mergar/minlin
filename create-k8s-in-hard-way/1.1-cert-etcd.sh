#!/bin/sh
mkdir -p pki && cd pki

cat >etcd-openssl.cnf<<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
subjectAltName = IP:172.16.0.50,IP:127.0.0.1
EOF

openssl genrsa -out etcd.key 2048
openssl req -new -key etcd.key -subj "/CN=etcd" -config etcd-openssl.cnf -out etcd.csr
openssl x509 -req -in etcd.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out etcd.crt -extensions v3_req -extfile etcd-openssl.cnf -days 365
