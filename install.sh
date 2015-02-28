#! /bin/bash

if (( $# < 2 )); then
	echo "Insufficient parameters"
	echo "Usage: $0 HOSTNAME ROOT_PARTITION EFI_PARTITION [SWAP_PARTITION]"
	echo "All partitions are of the format 'sdxY', for example 'sda1'"
	exit
fi

HOSTNAME="$1"
ROOT="/dev/$2"
EFI="/dev/$3"
SWAP="/dev/$4"

## Create partition format
mkfs.ext4 $ROOT
mkfs.vfat -F32 $EFI
if [ "$SWAP" != "" ]; then
	mkswap $SWAP
	swapon $SWAP
fi

## Mount All The Things!
mount $ROOT /mnt
mkdir /mnt/boot
mount $EFI /mnt/boot

## Install base system
pacstrap /mnt base base-devel dosfstools efibootmgr gummiboot

## Generate an FSTAB
genfstab -U /mnt > /mnt/etc/fstab

## Copy next script into chroot env
cp chroot.sh /mnt

## chroot in and run those steps!
arch-chroot /mnt /chroot.sh $ROOT $HOSTNAME
rm /mnt/chroot.sh
