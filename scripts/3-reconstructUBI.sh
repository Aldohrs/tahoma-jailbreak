#!/bin/bash

if [[ $# -ne 7 ]]; then
	echo "Usage: $0 <dtb_file> <kboot> <security> <persistent> <root> <apps> <rootB>"
	exit;
fi

echo "Creating a new UBI image"
echo "YOU SHOULD CHANGE THE SIZES ACCORDINGLY WITH WHAT IS SPECIFIED IN /persistent/boot/update"
echo "
[dtb]
mode=ubi
image=$1
vol_id=0
vol_size=126976
vol_type=static
vol_name=dtb
vol_alignment=1

[dtb-spare]
mode=ubi
image=$1
vol_id=1
vol_size=126976
vol_type=static
vol_name=dtb-spare
vol_alignment=1

[kboot]
mode=ubi
image=$2
vol_id=2
vol_size=4962064
vol_type=static
vol_name=kboot
vol_alignment=1

[kboot-spare]
mode=ubi
image=$2
vol_id=3
vol_size=4962064
vol_type=static
vol_name=kboot-spare
vol_alignment=1

[security]
mode=ubi
image=$3
vol_id=4
vol_size=126976
vol_type=static
vol_name=security
vol_alignment=1

[security-spare]
mode=ubi
image=$3
vol_id=5
vol_size=126976
vol_type=static
vol_name=security-spare
vol_alignment=1

[persistent]
mode=ubi
image=$4
vol_id=6
vol_size=3174400
vol_type=dynamic
vol_name=persistent
vol_alignment=1

[root]
mode=ubi
image=$5
vol_id=7
vol_size=34664448
vol_type=dynamic
vol_name=root
vol_alignment=1

[apps]
mode=ubi
image=$6
vol_id=8
vol_size=31490048
vol_type=dynamic
vol_name=apps
vol_alignment=1

[rootB]
mode=ubi
image=$7
vol_id=9
vol_size=34664448
vol_type=dynamic
vol_name=rootB
vol_alignment=1
" > config.ini
ubinize -o ubi-volume.bin -p 131072 -m 2048 -O 2048 -s 512 -Q 1056559212 config.ini
rm config.ini
