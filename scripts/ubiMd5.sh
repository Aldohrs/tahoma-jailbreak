#!/bin/bash

if [[ $# -ne 2 ]] && [[ $# -ne 1 ]]; then
        echo "Usage: $0 <ubi_vol_num> [<size>]"
        exit;
fi


id=$1
dev="/dev/ubi0_$id"

if grep -q static "/sys/class/ubi/ubi0/ubi0_${id}/type"; then
  size=$(cat "/sys/class/ubi/ubi0/ubi0_${id}/data_bytes")
  md5hash=$(dd if="$dev" count=1 bs="$size" 2>/dev/null | md5sum | cut -d " " -f 1)
else
  if [ -z "$2" ]; then
    echo "The size parameter is necessary for dynamic volumes"
    exit
  fi
  bs=$(cat "/sys/class/ubi/ubi0/ubi0_${id}/usable_eb_size")
  size=$2
  count=$(( (size + bs - 1) / bs))
  md5hash=$(dd if="$dev" count="$count" bs="$bs" 2>/dev/null | md5sum | cut -d " " -f 1)
fi

echo "$md5hash"

