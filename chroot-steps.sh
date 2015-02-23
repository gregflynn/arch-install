#! /bin/bash

if ! $# -eq 1 then
	echo "Insufficent parameters"
	echo "Usage: ./chroot-setup.sh HOSTNAME"
	exit
fi

LOCALE="en_US.UTF-8"

## Write the locale
echo "$LOCALE UTF-8" > /etc/locale.gen

## Generate locale data
locale-gen

## Create locale.conf
echo "LANG=$LOCALE" > /etc/locale.conf

export LANG=$LOCALE

## Timezone!
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

## Clock!
hwclock --systohc --utc

## Hostname
HOSTNAME=$1
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1	localhost.localdomain	localhost $HOSTNAME" > /etc/hosts
echo "::1	localhost.localdomain	localhost $HOSTNAME" >> /etc/hosts

## root password
echo "Enter the ROOT password"
passwd

echo "All set, configure network connection then run bootloader install"
