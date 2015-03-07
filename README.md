# arch-install
Scripts for pre, chroot, and post installation of Arch Linux

All scripts within this repository are provided as is with no warranty or guarantee that they will bring you happiness. Values within are hardcoded for my use case and may not be preferable for yours.

USE AT YOUR OWN RISK

# Installation steps
1. Copy all scripts to Arch Live USB
2. Make partitions via the Arch Linux instructions
    * Note: Scripts require 1 root partition, 1 EFI boot partition, and optionally a swap partition
3. Connect to the internet
4. run /run/archiso/bootmnt/arch-install/install.sh
