#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <already_mounted_folder>"
	exit;
fi

echo "Unmounting root, rootB and apps folders - if the size changed significatively, please ensure to update it"
sudo umount $1/root
sudo umount $1/rootB
sudo umount $1/apps

echo "Squashing the security folder and flashing it to the simulated NAND"
sudo mksquashfs $1/security security.sqsh -all-root
sudo ubiupdatevol /dev/ubi0_4 security.sqsh
sudo ubiupdatevol /dev/ubi0_5 security.sqsh

sudo rm security.sqsh

echo "Calculating all MD5 hashs that have to be added to /persistent/boot/update/"
echo "YOU SHOULD CHANGE THE SIZES ACCORDINGLY WITH WHAT IS SPECIFIED IN /persistent/boot/update"
echo -n "Security: "
echo $(sudo ./ubiMd5.sh 4)
echo -n "Apps: "
echo $(sudo ./ubiMd5.sh 8 12824576)
echo -n "Root: "
echo $(sudo ./ubiMd5.sh 7 17903616)
echo -n "RootB: "
echo $(sudo ./ubiMd5.sh 9 21839872)
