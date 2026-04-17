#!/bin/sh
rm -rf /root/kernel
make -C /usr/src kernel DESTDIR="/root/kernel" KERNCONF=FIRECRACKER -DWITHOUT_CLEAN
sync
sleep 5
du -sh /root/kernel/boot/kernel/kernel
