#! /bin/bash

## Post installtion tasks!

## install the best aur script
curl aur.sh > /mnt/usr/bin/aur.sh
chmod +x /mnt/usr/bin/aur.sh

## Add a user
arch-chroot /mnt useradd -m -G wheel -s /bin/bash greg

## blacklist pcspkr!
echo "blacklist pcspkr" > /mnt/etc/modprobe.d/nobeep.conf

## blacklist the crappy r8723au driver
echo "blacklist r8723au" > /mnt/etc/modprobe.d/r8723au.conf
