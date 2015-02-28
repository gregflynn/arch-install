#! /bin/bash

if (( $# != 2 )); then
	echo "Insufficent parameters"
	echo "Usage: $0 ROOT_PARTITION HOSTNAME"
	echo "Root partition must be of the format '/dev/sdxY', for example /dev/sda1"
	exit
fi

ROOT="$1"
HOSTNAME="$2"

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
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost $HOSTNAME" > /etc/hosts
echo "::1	localhost.localdomain	localhost $HOSTNAME" >> /etc/hosts

echo "Enter the ROOT password"
passwd

echo "Installing bootloader..."
BOOT="/boot"
#pacman -S dosfstools efibootmgr gummiboot
gummiboot --path=$BOOT install

## Write Arch bootloader conf
echo "title	Arch Linux" > $BOOT/loader/entries/arch.conf
echo "linux	/vmlinuz-linux" >> $BOOT/loader/entries/arch.conf
echo "initrd	/initramfs-linux.img" >> $BOOT/loader/entries/arch.conf
echo "options	root=$ROOT rw" >> $BOOT/loader/entries/arch.conf
echo "default	arch" > $BOOT/loader/loader.conf
echo "timeout	1" >> $BOOT/loader/loader.conf

echo "Done!"
