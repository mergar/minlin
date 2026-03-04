#!/bin/sh
cat << 'EOF' > /mnt/target/startup.nsh
\EFI\BOOT\BOOTX64.EFI initrd=\EFI\initrd.img console=ttyS0
EOF

umount /mnt/target

