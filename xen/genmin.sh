#!/bin/sh

# PREPARE
# apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev bc
# apt install linux-source
#cd /usr/src
#tar xvf linux-source-6.12.tar.xz

cd /usr/src/linux-source-6.12

# Копируем текущий конфиг Debian как базу
cp /boot/config-$(uname -r) .config

yes "" | make localyesconfig

scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS

# 1. Полностью отключаем подписи модулей (они не нужны в монолите)
scripts/config --disable MODULE_SIG
scripts/config --disable MODULE_SIG_ALL
scripts/config --disable MODULE_SIG_KEY

# 2. Очищаем пути к сертификатам, которые Debian тянет из дефолтного конфига
scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str SYSTEM_REVOCATION_KEYS ""

# 3. Отвечаем "нет" на вопрос о создании доверенного ринга
scripts/config --disable SYSTEM_TRUSTED_KEYRING

# Remove debug symbols (This is the most important for size)
scripts/config --disable DEBUG_INFO
scripts/config --disable DEBUG_KERNEL
scripts/config --disable SLUB_DEBUG

# Optimize for size
scripts/config --enable CC_OPTIMIZE_FOR_SIZE

# Ensure LZ4 compression for fast boot
scripts/config --enable KERNEL_LZ4

# Disable RAID6 benchmarking
scripts/config --disable RAID6_PQ_BENCHMARK

# Disable Parallel Port (LP) probing
scripts/config --disable PRINTER
scripts/config --disable PARPORT

scripts/config --disable DRM


# XEN
scripts/config --enable CONFIG_XEN_PVH
scripts/config --enable CONFIG_XEN_PVHVM
scripts/config --enable CONFIG_XEN
scripts/config --enable CONFIG_XEN_PVHVM
scripts/config --enable CONFIG_XEN_PVH


#3. One More "Speed Hack": Disable Predictable Network Interface Names
#To avoid the kernel/systemd waiting for networking udev rules:
#    Add net.ifnames=0 to your kernel command line.
#    In the kernel config, you can also disable CONFIG_DRM (Direct Rendering Manager) since bhyve guests are usually headless. This saves significant initialization time.

#One final check: Before you run kexec, make sure your new kernel actually has the VirtIO block driver built-in, or it won't see /dev/vda1 at all:
#grep CONFIG_VIRTIO_BLK .config
## It MUST be =y (not =m)
