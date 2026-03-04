#!/bin/bash
# 1. Создаем структуру заново
rm -rf init_tmp
mkdir -p init_tmp/{bin,dev,proc,sys,lib,lib64}

# 2. Копируем сам dash
#cp /usr/bin/dash init_tmp/bin/sh

cp /usr/sbin/switch_root /bin/

for lib in $(ldd /usr/sbin/switch_root | grep -o '/lib[^ ]*'); do
    cp --parents "$lib" init_tmp/
done

# 3. Копируем зависимости (библиотеки)
# Команда ldd покажет, что нужно dash. Обычно это libc и ld-linux.
# Мы скопируем их автоматически:
#for lib in $(ldd /usr/bin/dash | grep -o '/lib[^ ]*'); do
#    cp --parents "$lib" init_tmp/
#done
cp /usr/bin/busybox init_tmp/bin/

cd init_tmp/bin/
ln -s busybox ip
ln -s busybox sh
ln -s busybox mount
ln -s busybox umount

cd /root/minlin/minlin/diskprepare-uki


# 4. Создаем скрипт /init, который вызовет dash
cat << 'EOF' > init_tmp/init
#!/bin/busybox sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "----------------------------------------"
echo "WELCOME TO SHELL"
echo "----------------------------------------"
# Запускаем интерактивный шелл на консоли

# Настройка сети (статический IP)
ip link set eth0 up
ip addr add 172.16.0.50/24 dev eth0
ip route add default via 172.16.0.1

# Монтирование 9P (если расшарено с хоста)
# mkdir /mnt/shared
# mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/shared

echo "NETWORK CONFIGURED: eth0 = 172.16.0.50"
echo "MOUNT: mount -t 9p -o trans=virtio,version=9p2000.L,msize=1048576 share1 /mnt"

mkdir /newroot
# Опция msize=1048576 (1MB) сильно ускоряет работу 9p
mount -t 9p -o trans=virtio,version=9p2000.L,msize=1048576 share1 /newroot

# Проверяем, что в новой корне есть /sbin/init или /bin/sh
if [ -x /newroot/sbin/init ]; then
	echo "Switching to 9p root..."
	# Удаляем всё из текущего ramfs перед переходом, чтобы освободить RAM
	# switch_root: <new_root> <init_binary>
	exec /bin/switch_root /newroot /sbin/init
else
	echo "Error: /sbin/init not found on 9p share!"
	exec /bin/sh
fi

EOF

chmod +x init_tmp/init

# 5. Упаковываем
cd init_tmp && find . | cpio -H newc -o | gzip > ../initrd.img && cd ..
