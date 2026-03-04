#!/bin/sh
[ -d initramfs ] && rm -rf initramfs
mkdir -p initramfs/{bin,dev,proc,sys}
cd initramfs

# Создаем скрипт запуска
cat << 'EOF' > init
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "----------------------------"
echo "HELLO FROM CUSTOM KERNEL!"
echo "----------------------------"
exec /bin/sh # Оставим консоль, чтобы система не ушла в Kernel Panic
EOF

chmod +x init

# Если нужно 'hello world' на C, можно скомпилировать статически:
# gcc -static hello.c -o init

# Запаковываем в архив
find . | cpio -H newc -o | gzip > ../initrd.img
cd ..
