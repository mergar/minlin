#!/bin/sh
# Определяем версию (например, v1.35.1)

if [ ! -r ./runc.amd64 ]; then
	wget https://github.com/opencontainers/runc/releases/download/v1.4.0/runc.amd64
fi
chmod +x runc.amd64
cp -a runc.amd64 /k8s/runc

echo "!!!!!"
echo "НУЖНО ДОБАВИТЬ В ОБЩИЙ PATH на нодах!!!"
cp -a /k8s/runc /bin/
