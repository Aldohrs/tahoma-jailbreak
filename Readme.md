# Reverse Engineering the TaHoma

## Introduction

This is the main repository gathering the information available about the Somfy TaHoma, a multi-protocol domotic box usable through a dedicated cloud (let apart HomeKit).

The main objective is to document everything relevant to understand the internal working of the device to be able to effectively control it directly or with private servers.

As their architecture is similar, most of the information here should be valid for other Kizbox like:

* The TaHoma v2 (main study subject)
* The CozyTouch aka Kizbox Mini (many similarities)
* Any other box codenamed Kizbox (Kizbox v3?)

## Jailbreak instructions

To jailbreak the Somfy TaHoma, just follow [this link](./doc/Jailbreak.md)

## Documentation

* [TaHoma hardware specification and architecture](./doc/TaHomaHW.md)
* [KizOS boot process](./doc/KizOSBootProcess.md)
* [Firmware layout](./doc/FWLayout.md)
* [Somfy applications](./doc/SomfyApps.md)
* The dbus IPC system (TODO)
* [CloudLink and TCP+EAP specification](./doc/CloudLink.md) (WIP)
  * [Man-in-the-Middle attack on the CloudLink](./doc/SSLMitm.md)

## Contribute

If you were able to jailbreak your device and have more information, don't hesitate to send a PR here or open an issue and you will be added to the project.