#!/bin/bash
# 1. Создаем структуру заново
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

# 4. Создаем скрипт /init, который вызовет dash
cat << 'EOF' > init_tmp/init
#!/bin/dash
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "----------------------------------------"
echo "WELCOME TO DASH SHELL"
echo "----------------------------------------"
# Запускаем интерактивный шелл на консоли
exec /bin/dash
EOF

chmod +x init_tmp/init

# 5. Упаковываем
cd init_tmp && find . | cpio -H newc -o | gzip > ../initrd.img && cd ..
