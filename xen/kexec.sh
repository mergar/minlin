#!/bin/sh

# apt install kexec-tools


# Path to your freshly built kernel
KERNEL_PATH="/usr/src/linux-source-6.12/arch/x86/boot/bzImage"

#cat /proc/cmdline
#BOOT_IMAGE=/boot/vmlinuz-6.12.63+deb13-amd64 root=UUID=a049dab5-fed1-4984-8978-d22714f92441 ro quiet
# lsblk -f
#NAME   FSTYPE  FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
#sr0    iso9660       cidata 2026-03-02-11-12-59-00                              
#vda                                                                             
#├─vda1 vfat    FAT32        A66E-1863                             228.9M     4% /boot/efi
#└─vda2 ext4    1.0          a049dab5-fed1-4984-8978-d22714f92441   31.6G    15% /


# Load it
kexec -l $KERNEL_PATH --append="root=/dev/vda2 rw console=ttyS0 earlyprintk=serial"
kexec -e
