# Firmware layout

## NAND flash

The NAND flash is organized in 2 parts: the "bootstrap" which corresponds to the 2nd-level bootloader and that is located in the first block of the NAND flash memory (address < 0x20000) and the UBI volume system containing the rest.

The bootstrap entry point is located after 52 32-bit words configuring the hardware acceleration for the SAMA5D31 for error correction code.

## UBI

The UBI system is divided in several volumes:

| ID |       name       |                                              description                                            |  type   |          filesystem        |
|----|------------------|-----------------------------------------------------------------------------------------------------|---------|----------------------------|
| 0  | dtb              | the Device Tree allowing Linux to boot (mandatory in the ARM world)                                 | static  | none                       |
| 1  | dtb-spare        | copy of the DTB if it ever gets corrupted                                                           | static  | none                       |
| 2  | kboot            | initramfs image called after the bootstrap                                                          | static  | none (zImage + DTB + CPIO) |
| 3  | kboot-spare      | copy of the initramfs image if it gets corrupted                                                    | static  | none (zImage + DTB + CPIO) |
| 4  | security         | volume containing all the information specific to the device (certificates, environment, MAC, etc.) | static  | squashfs                   |
| 5  | security-spare   | again a copy to ensure reliability                                                                  | static  | squashfs                   |
| 6  | persistent       | dynamic information that must be saved upon reboots                                                 | dynamic | ubifs                      |
| 7  | root             | primary root partition for KizOS                                                                    | dynamic | ubifs                      |
| 8  | apps             | partition used to store userland applications and home automation saves                             | dynamic | ubifs                      |
| 9  | rootB            | alternate root partition for KizOS                                                                  | dynamic | ubifs                      |
| 10 | persistent-spare | unused on the TaHoma and appeared with recent KizOS versions, probably used for reliability         | dynamic | ubifs?                     |

## Root filesystem

Once every volume is mounted the root filesystem looks like this (cf. `/etc/fstab` for details):

|      path     |                                          description                                           |
|---------------|------------------------------------------------------------------------------------------------|
| Linux paths   | all Linux standard paths are used accordingly to their roles*                                  |
| /apps         | Overkiz specific applications for home automation and data (cf. below)                         |
| /etc/security | mount point of the security volume                                                             |
| /persistent   | contains data that must be saved upon reboots (update information, cache, etc.)                |
| /www          | used to contain static files for the web application allowing to use the rest API from `local` |

\* only tmp is symlinked to /var/tmp to ensure that it lives only on RAM

## The apps filesystem

This filesystem contains all the data related to the actual management of the house automation system.

`/apps/usr` only seems to contain software linked to the update process. `/apps/overkiz` contains all the actual applications. They may call librairies and binaries located elsewhere but this is the most interesting path.

The apps details are located in their own page but here are some common things:

| overkiz subpath |                                                     description                                                     |
|-----------------|---------------------------------------------------------------------------------------------------------------------|
| dispatcher      | contains the configuration of the cloud connection (updates and instructions)                                       |
| http-log        | an application dedicated to send any log with a level >= ERROR to the Overkiz log server                            |
| internal        | the application that orchestrates the others, it handles network connection and reboot among others                 |
| lib             | contains common binary librairies and lua objects common to all the applications (bus acces, logging, etc.)         |
| local           | the application that allow to manage the TaHoma from the embedded REST API (the web server is disabled by default)* |
| lua             | ???                                                                                                                 |
| share           | contains provisionning information for other applications (knowledge databases, STM32 firmware, etc.)               |

The other folders contain mostly protocol specific applications.

\* For more details see https://www.lafois.com/2020/12/20/rooting-the-cozytouch-aka-kizbox-mini-part-5

### The share folder

As stated above, the share folder contains interesting files for the reverse engineering.

For example the `/apps/overkiz/share/io-homecontrol` folder contains the "daughterboard" STM32 firmware along the scripts used to update the microprocessor.

The `/apps/overkiz/share/knowledge` folder contains all the sqlite databases that allow the applications to support specific devices. So the `/apps/overkiz/share/knowledge/io/ref-local-io.db` file is a sqlite file containing the information about all io-homecontrol devices supported by the TaHoma. These files are updated independently from the firmware and are directly pulled from Overkiz' cloud.