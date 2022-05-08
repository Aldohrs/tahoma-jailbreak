# Information related to the Linux Kernel for TaHoma

## Somfy's Linux

Boot CMD:

    panic=5 oops=panic rootfstype=ubifs ubi.mtd=ubi loglevel=2 ro

Device Tree compatible: `overkiz,kizbox2-2atmel,sama5d31atmel,sama5d3atmel,sama5`

Device Tree boot args: `panic=5 oops=panic rootfstype=ubifs ubi.mtd=ubi loglevel=2 ro root=ubi0:root`

## Openkizos Linux

at91bootstrap nearly unmodified to boot into u-boot. Could be modified to add LED support

U-Boot from uboot-at91 configured to load a custom FIT image containing the zImage from mainline Linux along with a custom DTB. Configuration of U-Boot must be modified.

Kernel from linux mainline with modified device Tree. The config must also be changed. Additional DTB are required for Kizbox other than TaHoma with 2 heads.

rootfs in UBI format from buildroot with additional init scripts for network, USB and LEDs. In the future: an automount and autolaunch script for booting Linux on a USB key.

CMD line: `loglevel=6 console=ttyS0,115200 mtdparts=atmel_nand:256k(bootstrap)ro,768k(uboot)ro,256k(env_redundant),256k(env),6656k(itb)ro,-(ubi) rootfstype=ubifs ubi.mtd=5 root=ubi0:rootfs rw`

More details: https://github.com/Aldohrs/openkizos