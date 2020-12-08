#!/bin/bash

sudo umount /dev/ubi0_*
sudo ubidetach -p /dev/mtd0
sudo rmmod ubifs ubi nandsim
