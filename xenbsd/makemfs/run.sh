#!/bin/sh

mkdir -p my_root/sbin
mkdir -p my_root/dev
mkdir -p my_root/etc

# Копируем сам init
cp /sbin/init my_root/sbin/

# Копируем зависимости (обязательно для стандартного init)
mkdir -p my_root/libexec
cp /libexec/ld-elf.so.1 my_root/libexec/
mkdir -p my_root/lib
ldd /sbin/init | awk '{print $3}' | xargs -I{} cp {} my_root/lib/


makefs -s 5m -B little mfsroot.img my_root/
