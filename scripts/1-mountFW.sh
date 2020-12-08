#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <dump_file> <mount_folder>"
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
echo "Mounting all UBIFS volumes (check the ubinfo above if you encounter errors here)..."
mkdir -p $2/persistent
mkdir $2/root
mkdir $2/rootB
mkdir $2/apps
sudo mount -t ubifs -o rw /dev/ubi0_6 $2/persistent
sudo mount -t ubifs -o rw /dev/ubi0_7 $2/root
sudo mount -t ubifs -o rw /dev/ubi0_8 $2/apps
sudo mount -t ubifs -o rw /dev/ubi0_9 $2/rootB

echo "Unpacking squashfs volumes..."
mkdir $2/security
mkdir $2/security-spare
sudo unsquashfs -d $2/security /dev/ubi0_4
sudo unsquashfs -d $2/security-spare /dev/ubi0_5

