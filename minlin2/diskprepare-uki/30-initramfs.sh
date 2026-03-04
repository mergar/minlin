#!/bin/bash
# 1. Создаем структуру заново
apt-get install busybox-static

rm -rf init_tmp
mkdir -p init_tmp/{bin,dev,proc,sys,lib,lib64}

# 2. Копируем сам dash
cp /usr/bin/dash init_tmp/bin/dash

# 3. Копируем зависимости (библиотеки)
# Команда ldd покажет, что нужно dash. Обычно это libc и ld-linux.
# Мы скопируем их автоматически:
for lib in $(ldd /usr/bin/dash | grep -o '/lib[^ ]*'); do
    cp --parents "$lib" init_tmp/
done

mkdir -p init_tmp/bin
cp /usr/bin/busybox init_tmp/bin/busybox

cat << 'EOF' > init_tmp/init
#!/bin/busybox sh
# Устанавливаем пути к командам через busybox
/bin/busybox --install -s /bin

mount -t proc proc /proc
mount -t sysfs sysfs /sys

# Настройка сети (статический IP)
ip link set eth0 up
ip addr add 172.16.0.50/24 dev eth0
ip route add default via 172.16.0.1

# Монтирование 9P (если расшарено с хоста)
# mkdir /mnt/shared
# mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/shared

echo "NETWORK CONFIGURED: eth0 = 172.16.0.50"
exec /bin/sh
EOF

chmod +x init_tmp/init
cd init_tmp && find . | cpio -H newc -o | gzip > ../initrd.img && cd ..
