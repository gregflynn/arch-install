#! /bin/bash

if ! $# -eq 3 then
	echo "Insufficient parameters"
	echo "./pre.sh [root partition (sda1)] [efi partition (sda2)] [swap partition (sda3)]"
	exit
fi

ROOT="/dev/$1"
EFI="/dev/$2"
SWAP="/dev/$3"

## Create partition format
mkfs.ext4 $ROOT
mkfs.vfat -F32 $EFI
mkswap $SWAP
swapon $SWAP

## Mount All The Things!
mount $ROOT /mnt
mkdir /mnt/boot
mount $EFI /mnt/boot

## Install base system
pacstrap /mnt base base-devel

## Generate an FSTAB
genfstab -U /mnt > /mnt/etc/fstab

## Copy next script into chroot env
cp chroot-steps.sh /mnt
cp bootloader.sh /mnt
cp post.sh /mnt

echo "ready to chroot!"
echo "arch-chroot /mnt /bin/bash"
