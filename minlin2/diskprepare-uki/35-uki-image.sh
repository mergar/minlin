#!/bin/sh
apt-get update && apt-get install -y systemd-boot binutils systemd-boot-efi


objcopy \
    --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
    --add-section .cmdline=cmdline.txt --change-section-vma .cmdline=0x30000 \
    --add-section .initrd=initrd.img --change-section-vma .initrd=0x40000 \
    --add-section .linux=/usr/src/linux-source-6.12/arch/x86/boot/bzImage --change-section-vma .linux=0x2000000 \
    /usr/lib/systemd/boot/efi/linuxx64.efi.stub BOOTX64.EFI
