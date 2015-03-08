#! /bin/bash

if (( $# < 4 )); then
	echo "Insufficient parameters"
	echo "Usage: $0 HOSTNAME USER ROOT_PARTITION EFI_PARTITION [SWAP_PARTITION]"
	echo "All partitions are of the format 'sdxY', for example 'sda1'"
	exit
fi

HOSTNAME="$1"
USER="$2"
ROOT="/dev/$3"
EFI="/dev/$4"
SWAP="/dev/$5"

## Create partition format
mkfs.ext4 -F $ROOT
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
PACKAGES=`sed ':a;N;$!ba;s/\n/ /g' packages.txt`
pacstrap /mnt base base-devel $PACKAGES

## Generate an FSTAB
genfstab -U /mnt > /mnt/etc/fstab

## Copy next script into chroot env
cp chroot.sh /mnt

## chroot in and run those steps!
arch-chroot /mnt /chroot.sh $ROOT $HOSTNAME
rm /mnt/chroot.sh

## Add a user
arch-chroot /mnt useradd -m -G wheel -s /bin/bash $USER
echo "Enter user password"
arch-chroot /mnt passwd $USER

## AUR package installer
AUR_PACKAGES=`sed ':a;N;$!ba;s/\n/ /g' aur-packages.txt`
AURSH="/mnt/home/$USER/install-aur.sh"
echo "#! /bin/bash"                        > $AURSH
echo "sudo curl aur.sh > /usr/bin/aur.sh" >> $AURSH
echo "sudo chmod +x /usr/bin/aur.sh"      >> $AURSH
echo "mkdir /home/$USER/aur"              >> $AURSH
echo "cd /home/$USER/aur"                 >> $AURSH
echo "aur.sh -si $AUR_PACKAGES"           >> $AURSH
chmod +x /mnt/home/$USER/install-aur.sh

## blacklist pcspkr!
echo "blacklist pcspkr" > /mnt/etc/modprobe.d/nobeep.conf

## blacklist the crappy r8723au driver
echo "blacklist r8723au" > /mnt/etc/modprobe.d/r8723au.conf
