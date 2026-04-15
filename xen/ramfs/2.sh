#!/bin/sh
cd my-unikernel
find . | cpio -H newc -o | gzip > ../initrd.img


