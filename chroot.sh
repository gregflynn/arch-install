#! /bin/bash

if ! $# -eq 2 then
	echo "Insufficent parameters"
	echo "Usage: ./chroot.sh ROOT_PARTITION HOSTNAME"
	exit
fi

echo "Setting up locale..."
LOCALE="en_US.UTF-8"
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
export LANG=$LOCALE

echo "Setting timezone..."
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

echo "Setting hardware clock to UTC..."
hwclock --systohc --utc

echo "Writing hostname information..."
HOSTNAME=$2
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost $HOSTNAME" > /etc/hosts
echo "::1	localhost.localdomain	localhost $HOSTNAME" >> /etc/hosts

echo "Enter the ROOT password"
passwd

echo "Installing bootloader..."
BOOT="/boot"
ROOT=$1
pacman -S dosfstools efibootmgr gummiboot
gummiboot --path=$BOOT install

## Write Arch bootloader conf
echo "title	Arch Linux" > $BOOT/loader/entries/arch.conf
echo "linux	/vmlinuz-linux" >> $BOOT/loader/entries/arch.conf
echo "initrd	/initramfs-linux.img" >> $BOOT/loader/entries/arch.conf
echo "options	root=/dev/$ROOT rw" >> $BOOT/loader/entries/arch.conf
echo "default	arch" > $BOOT/loader/loader.conf
echo "timeout	1" >> $BOOT/loader/loader.conf

echo "Done! Ready for post installation!"

echo "All set, configure network connection then run bootloader install"
