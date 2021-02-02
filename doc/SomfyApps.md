# Somfy Applications

There are many Somfy applications on the TaHoma. Here is a quick summary, most of them are obvious:

* aurora: handles the Aurora protocol
* dispatcher: contains the configuration of the cloud connection (updates and instructions)
* enocean: handles the EnOcean protocol
* homekit: handles Apple HomeKit
* http-log: an application dedicated to send any log with a level >= ERROR to the Overkiz log server
* internal: the application that orchestrates the others, it handles network connection and reboot among others
* io-homecontrol: handles the io-homecontrol protocol
* knx-ip: handles the KNX protocol
* lib: contains common binary librairies and lua objects common to all the applications (bus acces, logging, etc.)
* local: the application that allow to manage the TaHoma from the embedded REST API (the web server is disabled by default)
* lua: **???**
* modbus: handles the modbus protocol
* network: handles some protocols over IP like Philips Hue, UPnP, etc.
* ogp: **home automation protocol?**
* ows: handles the conversion from dbus events to CloudLink messages based on plugins
* profalux868: handles the proprietary protocol Profalux
* ramses: handles the evohome protocol
* rtd: **linked to modbus???**
* rtds: **linked to modbus???**
* rtn: **???**
* rts: handles the Somfy RTS protocol
* rtx: **???**
* share: contains provisionning information for other applications (knowledge databases, STM32 firmware, etc.)
* trigger: **???**
* xcomfort: handles Eaton xComfort, another closed-specification protocol
* yokis: handles yokis protocol
* zigbee: handles the Zigbee protocol
* zwave: handles the Zwave protocol

## Organization

The applications are either native or compiled in luaJIT. In the latter case decompilators exist but are incomplete and will only give an idea of the actual program.

Most of the applications are organized the following way:

* `bin`: contains the entrypoint executable (that may be in fact plain uncompiled lua)
* `etc`: contains configuration and runtime data (for exemple node database for protocols)
* `lib`: contains the luajit code for the application
 * This folder is configured as namespaces and class names, it will alway contain the `Overkiz/HomeAutomation` path
 * The `Protocol` sub namespace contains the main code for the application
 * The `Shared` sub namespace contains common code for several protocols if the application handles several protocols
 * The `Utils` sub namespace... Well every project big enough contains a Utils folder
 * The `Bus` namespace refers to everything linked to the dbus IPC
