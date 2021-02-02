# KizOS boot process

The Linux distribution on Somfy's TaHoma's boxes is called KizOS and is constitued of a custom-compiled Linux Kernel (4.14 on KizOS version 2020.6.4-15...) with a custom-built rootfs.

The boot process is as following:

* The SAMA5D3 bootROM is ran into the internal SRAM (128kB in total) of the SoC as is mapped at address 0x0
* This bootrom will initialize the basic functionalities of the SoC that will allow to load the 2nd-stage bootloader or start into the recovery mode (SAM-BA) if unable to locate the 2nd-stage bootloader. It is this piece of code that outputs "ROMboot" on the DBGU at startup.
* The 2nd-stage bootloader is located at the beginning of the NAND flash memory and is a custom built bootloader based on the open source code published by Atmel. It will initialize the external RAM and output the state on DBGU. It will then initialize the UBI system to locate and execute the next stage on the NAND flash memory.
* kboot is called from the 2nd-stage bootloader. It is a initramfs system (Linux kernel+minimal filesystem) in charge of initializing the first stages necessary to boot KizOS
* At last, kboot lets the control to the full KizOS system

## kboot

Based on Ubuntu's initramfs it performs several checks to ensure that KizOS is properly booted:

* It initializes the network controller
* It checks if an update is necessary or if one of the 2 rootfs of KizOS is corrupted. It will then decide on which rootfs the TaHoma should be booted
* Depending on what is configured in `/sys/kboot/next`, the boot process can also be modified (see below)

It is possible to unpack kboot's embedded filesystem with binwalk with the following command:

```
binwalk kboot.dmp -e -M -C out # out is the output folder for decompressed files
```

The most interesting files to understand what kboot does are located in the following paths (in the initramfs' rootfs):

* `/usr/bin/rsa_verify_crt`
* `/usr/share/kboot`
* `/etc/init.d`
* `/usr/sbin`

The `/sys/kboot/next` file specifies how the system should be rebooted if the reboot command is issued:

* 0: wait for an event on `/dev/input/event0`
* 1: boot from a USB key (see below)
* 2: executed when rebooting after an upgrade, flashes the volumes and swap the roots for KizOS
* 3: normal boot process
* 4: swap the rootfs to go on the previous KizOS version, used as a rollback if something went wrong
* 9: run factory tests

To boot on a USB drive, the following conditions must be met:

* The `/sys/kboot/next` pseudo-file must have been set to 1
* A USB drive properly formatted (FAT, ext3, etc.) must be connected
* The drive must contain at least 1 bootable file at the root: `zImage-at91-kizbox2.bin` or `zImage-initramfs-at91-kizbox2.bin`
* The files must be signed cryptographically with a certificate signed by `/etc/security/usb-codesign.crt`
* The drive must contain a bootvar file at the root: `at91-kizbox2-bootscript-vars`, it also must be signed

Unless `/usr/bin/rsa_verify_crt` has a flaw, it is not possible to jailbreak the TaHoma leveraging the USB port if it has not been jailbreaked before :(

It is not a big file to reverse though.