#!/bin/sh
mkdir -p /mnt/target
mount /dev/vdb1 /mnt/target

mkdir -p /mnt/target/EFI/BOOT

cp -a BOOTX64.EFI /mnt/target/EFI/BOOT/
chmod +x /mnt/target/EFI/BOOT/BOOTX64.EFI
# Копируем ваше ядро под именем загрузчика. EFISTUB
#cp /usr/src/linux-source-6.12/arch/x86/boot/bzImage /mnt/target/EFI/BOOT/BOOTX64.EFI

# Копируем initramfs рядом
#cp initrd.img /mnt/target/EFI/initrd.img

umount /mnt/target
