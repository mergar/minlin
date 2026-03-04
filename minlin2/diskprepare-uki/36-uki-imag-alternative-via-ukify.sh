#!/bin/sh
#Если вы используете Debian 13 (Trixie), там доступна утилита ukify, которая заменяет сложную команду objcopy и сама знает все пути к заглушкам. Это намного надежнее.

#    Установите её:
#    bash

apt-get install -y systemd-ukify

#    Use code with caution.
#    Соберите образ одной командой:
#    bash


/usr/lib/systemd/ukify build \
    --linux=/usr/src/linux-source-6.12/arch/x86/boot/bzImage \
    --initrd=initrd.img \
    --cmdline="console=ttyS0 net.ifnames=0 quiet" \
    --output=BOOTX64.EFI
