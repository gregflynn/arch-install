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

# download AUR script
# NOTE: this is done here because of the flakiness of the r8723au driver on my Lenovo Yoga 11s
mkdir -p /mnt/usr/bin
curl aur.sh > /mnt/usr/bin/aur.sh
chmod +x /mnt/usr/bin/aur.sh

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

## install AUR packages!
# NOTE: this is all commented out because it does not work but worth keeping around
# if I ever feel the urge to get this working
# AUR_PACKAGES=`sed ':a;N;$!ba;s/\n/ /g' packages.txt`
# if [ "$AUR_PACKAGES" != "" ]; then
#     echo "#! /bin/bash" > /mnt/home/$USER/install-aur.sh
#     echo "mkdir /home/$USER/aur" >> /mnt/home/$USER/install-aur.sh
#     echo "cd /home/$USER/aur" >> /mnt/home/$USER/install-aur.sh
#     echo "aur.sh $AUR_PACKAGES" >> /mnt/home/$USER/install-aur.sh
#     chmod +x /mnt/home/$USER/install-aur.sh
#     chroot --userspec=$USER:wheel /mnt /home/$USER/install-aur.sh
# fi

## blacklist pcspkr!
echo "blacklist pcspkr" > /mnt/etc/modprobe.d/nobeep.conf

## blacklist the crappy r8723au driver
echo "blacklist r8723au" > /mnt/etc/modprobe.d/r8723au.conf
