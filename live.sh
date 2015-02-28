#! /bin/bash

if (( $# < 2 )); then
	echo "Insufficient parameters"
	echo "Usage: $0 ROOT_PARTITION EFI_PARTITION [SWAP_PARTITION]"
	exit
fi

ROOT="/dev/$1"
EFI="/dev/$2"
SWAP="/dev/$3"

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
pacstrap /mnt base base-devel

## Generate an FSTAB
genfstab -U /mnt > /mnt/etc/fstab

## Copy next script into chroot env
cp chroot.sh /mnt

echo "ready to chroot!"
echo "arch-chroot /mnt /bin/bash"
