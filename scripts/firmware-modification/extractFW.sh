#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <dump_file> <path to export contents>"
	exit;
fi

echo "Preparing a simulated NAND memory"
sudo modprobe nandsim first_id_byte=0xec second_id_byte=0xa1 third_id_byte=0x00 fourth_id_byte=0x15;
sudo flash_erase /dev/mtd0 0 0
echo "Writing data to simulated flash"
sudo nandwrite /dev/mtd0 $1
sudo modprobe ubi
sudo ubiattach -p /dev/mtd0 -O 2048
echo "Here is the ubinfo from the flash"
ubinfo -a
echo "Dumping all volumes to files..."
mkdir -p $2/volumes
sudo dd if=/dev/ubi0_0 of=$2/volumes/dtb.dmp
sudo dd if=/dev/ubi0_1 of=$2/volumes/dtb-spare.dmp
sudo dd if=/dev/ubi0_2 of=$2/volumes/kboot.dmp
sudo dd if=/dev/ubi0_3 of=$2/volumes/kboot-spare.dmp
sudo dd if=/dev/ubi0_4 of=$2/volumes/security.dmp
sudo dd if=/dev/ubi0_5 of=$2/volumes/security-spare.dmp
sudo dd if=/dev/ubi0_6 of=$2/volumes/persistent.dmp
sudo dd if=/dev/ubi0_7 of=$2/volumes/root.dmp
sudo dd if=/dev/ubi0_8 of=$2/volumes/apps.dmp
sudo dd if=/dev/ubi0_9 of=$2/volumes/rootB.dmp
echo "Recreating the root filesystem with automounted volumes..."
mkdir $2/tmp_mount
mkdir $2/rootfs
sudo mount /dev/ubi0_7 $2/tmp_mount
sudo cp -R $2/tmp_mount/* $2/rootfs
sudo umount /dev/ubi0_7
sudo mount /dev/ubi0_6 $2/tmp_mount
sudo cp -R $2/tmp_mount/* $2/rootfs/persistent
sudo umount /dev/ubi0_6
sudo mount /dev/ubi0_8 $2/tmp_mount
sudo cp -R $2/tmp_mount/* $2/rootfs/apps
sudo umount /dev/ubi0_8
sudo unsquashfs -d $2/tmp_mount/security /dev/ubi0_4
sudo mv $2/tmp_mount/* $2/rootfs/etc/security/
echo "Cleaning..."
rmdir $2/tmp_mount
sudo ubidetach -p /dev/mtd0
sudo rmmod ubifs ubi nandsim
