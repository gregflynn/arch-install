#! /bin/bash

if ! $# -eq 1 then
	echo "Insufficient parameters"
	echo "Usage: ./bootloader.sh [root partition (sda1)]"
	exit
fi

BOOT="/boot"
ROOT=$1

## Install necessary packages from pacman
pacman -S dosfstools efibootmgr gummiboot

## Install gummiboot!
gummiboot --path=$BOOT install

## Write Arch bootloader conf
echo "title	Arch Linux" > $BOOT/loader/entries/arch.conf
echo "linux	/vmlinuz-linux" >> $BOOT/loader/entries/arch.conf
echo "initrd	/initramfs-linux.img" >> $BOOT/loader/entries/arch.conf
echo "options	root=/dev/$ROOT rw" >> $BOOT/loader/entries/arch.conf

echo "default	arch" > $BOOT/loader/loader.conf
echo "timeout	1" >> $BOOT/loader/loader.conf

echo "Done! Ready for post installation!"
