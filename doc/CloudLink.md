# CloudLink and TCP+EAP specification

## Introduction and usage

To get its commands, the TaHoma follows several steps (everything requires mutual authentication):

* First it gets the latest version name by calling `hxxps://ha-update.overkiz.com/envname`
* Then it calls the `/si.xconf` file on the same domain, it optionally specifies 2 GET parameters:
  * `supported-protocols` which specifies in a comma-separated list which protocols the TaHoma is capable of using with the server for the actual instructions and status. Example: `tcp+eap,http-bypass`
  * `distro` which is the current firmware version
* It also regurlarly calls the `/log` endpoint, still on the same domain, with POST requests to submit log information (mostly about time setting via NTP)
* It uses the `si.xconf` recovered to configure the "CloudLink" agent on the TaHoma. This is the actual client that will send states and receive commands when the user interacts with Somfy's web and mobile applications (see an example below)
* In the latest versions, the `tcp+eap` protocol is in use and looks like a custom protocol built onto a TLS socket.

Here is an example of the `si.xconf` file:

```xml
<?xml version="1.0" encoding="utf-8"?>
<connection name="HA101" protocol="tcp+eap" version="" retry-delay="30s" buffering-delay="500ms">
      <tls client="/etc/security/client.crt" authority="/etc/security/ca.crt" key="/etc/security/client.key"/>
      <http host="ha101-3.overkiz.com" port="443" path="connection-listener/cl" timeout="30s" connection-timeout="15s"/>
      <bypass algorithm="HMAC-SHA1" host="ha101-3.overkiz.com" port="18888" interval="20s" timeout="5s" retry="5" anti-replay="true" serial="/etc/security/ca.crt"/>
      <eap host="ha101-3.overkiz.com" port="802" handshake-timeout="15s" keep-alive="20s" server-timeout="30s" time-to-live="4h" max-queued="100"/>
      <log host="ha101-3.overkiz.com" port="443" path="connection-listener/log" backlog="0"/>
</connection>
```

The configuration options are obvious but here are the most notable ones:

* `protocol="tcp+eap"` sets the CloudLink application to use the information located in the eap tag to set up an EAP tunnel
* The tls tag sets up the required information to establish a trusted TLS connection with the web server and the EAP server
* The log tag allows the TaHoma to send error logs to the server, these logs are only sent if a log entry with a minimum level of ERROR is triggered in any application of the TaHoma.

You will need to set up an HTTPS server as specified [here](./SSLMitm.md) to be able to use the [web server](../scripts/web-update/). It's ugly, but it works. Just install Python3 and Django on your server (or a virtualenv) and run the following command `python3 manage.py runserver 8080` or on whatever port you proxied in nginx.

The `eapServer.py` file (not available yet) will provide a basic EAP server. You must provide the certificates in a similar manner as when you configured the webserver. It needs root access on Linux because Linux requires software that bind ports less than 1024 to be run as root (or the proper capability). You should be able to circumvent that by modifying the port both on the `si.xconf` and the `eapServer.py` sides.

## The protocol

This is a full duplex protocol and both the server and the client can send data without any request from the other part (unlike HTTP if that makes sense to you). It is built on top of a standard TLS connection that requires mutual authentication.

It is command-based, each command starting by an opcode which is binary. The command length is variable depending of the nature of the command. Then any data sent is plaintext in the form of XML documents that have the `<ozp>` tag for root.

Some commands, like the ones that send data, have an incremental sequence number (starting at zero when the first data command is sent by the TaHoma).

### Command set 

Bytes are represented as hexadecimal.

If a number is on several bytes, the MSB comes first.

| Bytes                         |      Command                                                                                          |
|-------------------------------|-------------------------------------------------------------------------------------------------------|
| 01 05 TT TT TT TT TT TT TT TT | Keepalive from the server with timestamp in milliseconds (64 bits)                                    |
| 03                            | Server Hello (immediatly sent by the server after the TLS handshake is finished)                      |
| 04 SS SS                      | ACK: data acknowledgement. SS SS is the sequence number of the data frame ACKed                       |
| 05 TT TT TT TT TT TT TT TT    | Keepalive from the client with timestamp in milliseconds (64 bits)                                    |
| 10 00 SZ SZ SZ data           | Data sent by the server to the client. SZ SZ SZ is the size of the data sent. data is an XML document |
| 10 40 SS SS SZ SZ SZ data     | Data sent by the client to the server. The terminology is the same as above                           |

Examples:

First sync sent by the TaHoma after booting up (beautified and anonymised). Note that is contains the information that wether the SSH server is active or not:

```xml
10 40 00 08 00 35 E6
<ozp>
	<pod seq-num="1" version="2020.x.x" timestamp="1619530662">
		<object type="json" id="admin">
			<![CDATA[[{"boot":{"bootmode":0,"rebootmode":3,"reset":"wakeup"}}]]]>
		</object>
		<object type="json" id="trigger">
			<![CDATA[[{"status" : { "value" : "ready"}}]]]>
		</object>
		<object type="json" id="knowledge">
			<![CDATA[[{"status" : { "value" : "ready"}},{"elements":[{"category":"utils","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"global"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"internal"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"io"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"zigbee"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"enocean"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"ovp"},{"category":"protocol:database","hash":"2ae66f90b7788ab8950e8f81b829c947","name":"rts"}]}]]]>
		</object>
		<object type="json" id="usb">
			<![CDATA[[{"devices":[{"device":{"devicereleasenumber":"0414","productdefinition":"EHCI Host Controller","deviceprotocol":"00","interfaceprotocol":"00","deviceclass":"09","interfacesubclass":"00","devicesubclasscode":"00","devicepath":"\/devices\/platform\/ahb\/700000.ehci\/usb1\/1-0:1.0","interfaceclass":"09","manufacturer":"Linux 4.14.199 ehci_hcd","version":" 2.00","vendorid":"1d6b","productid":"0002"}},{"device":{"devicereleasenumber":"0414","productdefinition":"USB Host Controller","deviceprotocol":"00","interfaceprotocol":"00","deviceclass":"09","interfacesubclass":"00","devicesubclasscode":"00","devicepath":"\/devices\/platform\/ahb\/600000.ohci\/usb2\/2-0:1.0","interfaceclass":"09","manufacturer":"Linux 4.14.199 ohci_hcd","version":" 1.10","vendorid":"1d6b","productid":"0001"}}]},{"status" : { "value" : "ready"}}]]]>
		</object>
		<object type="json" id="internal">
			<![CDATA[[{"state":{"value":"N\/A","node":"pod\/0","param":"ip"}},{"state":{"value":0,"node":"alarm\/0","param":"currentMode"}},{"state":{"value":"notDetected","node":"alarm\/0","param":"intrusion"}},{"state":{"value":0,"node":"alarm\/0","param":"targetMode"}},{"state":{"value":30,"node":"alarm\/0","param":"delay"}},{"state":{"value":"alarm name","node":"alarm\/0","param":"name"}},{"state":{"value":"at91-kizbox2-ec;at91-kizbox2-simu;at91-kizbox2-tahoma;at91-kizbox2;","node":"pod\/0","param":"supportedUI"}},{"state":{"value":"PG","node":"pod\/0","param":"countryCode"}},{"state":{"value":"no","node":"pod\/0","param":"batteryPowered"}},{"state":{"value":"yes","node":"pod\/0","param":"stateTrigger"}},{"state":{"value":"yes","node":"pod\/0","param":"calendarTrigger"}},{"state":{"value":0,"node":"pod\/0","param":"lightingLedPodMode"}},{"state":{"value":"5","node":"pod\/0","param":"commitedMemory"}},{"state":{"value":"ACTIVE","node":"pod\/0","param":"mode"}},{"state":{"value":"0.02","node":"pod\/0","param":"load"}},{"state":{"value":"at91-kizbox2-tahoma","node":"pod\/0","param":"UI"}},{"state":{"value":"13","node":"pod\/0","param":"usedMemory"}},{"state":{"value":[{"status":"active","hash":"2ae66f90b7788ab8950e8f81b829c947","version":"2020.x.x-xx","id":"root"},{"status":"active","hash":"2ae66f90b7788ab8950e8f81b829c947","version":"2020.x.x-xx","id":"apps"},{"status":"active","version":"unknown","id":"bootstrap"},{"status":"inactive","hash":"2ae66f90b7788ab8950e8f81b829c947","version":"2020.x.x-x","id":"rootB"},{"status":"active","hash":"2ae66f90b7788ab8950e8f81b829c947","version":"2020.xx-xxxxxxxxxxxxxx","id":"bootloader"},{"status":"active","id":"security"},{"status":"inactive","version":"unknown","id":"appsB"}],"node":"pod\/0","param":"updateStatus"}},{"state":{"value":"Box","node":"pod\/0","param":"name"}},{"state":{"value":"offline","node":"pod\/0","param":"networkConnectivity"}},{"state":{"value":"yes","node":"pod\/0","param":"stateTrigger"}},{"state":{"value":"ACTIVE","node":"pod\/0","param":"mode"}},{"state":{"value":"yes","node":"pod\/0","param":"calendarTrigger"}},{"status" : { "value" : "ready"}}]]]>
		</object>
		<object type="json" id="admin">
			<![CDATA[[{"systime":{"ntpreliable":true,"time-stamp":1619530662}},{"uptime":{"seconds":23}},{"systime":{"ntpreliable":true,"time-stamp":1619530662}},{"coredump":{"enabled":false}},{"ssh":{"enabled":true}},{"status" : { "value" : "ready"}}]]]>
		</object>
		<object type="json" id="internal">
			<![CDATA[[{"state":{"value":"online","node":"pod\/0","param":"networkConnectivity"}}]]]>
		</object>
	</pod>
	<pod version="2020.x.x" seq-num="2" timestamp="1619530662">
		<object id="io">
			<![CDATA[<io><status value="down" syncid="82e7ed95-4ed9-4a8f-bfb9-a749f5da4d68"/></io>]]>
		</object>
		<object id="ovp">
			<![CDATA[<ovp><status value="down" syncid="82e7ed95-4ed9-4a8f-bfb9-a749f5da4d68"/></ovp>]]>
		</object>
		<object id="ramses">
			<![CDATA[<ramses><status value="down"/></ramses>]]>
		</object>
		<object id="rtd">
			<![CDATA[<rtd><status value="down" syncid="82e7ed95-4ed9-4a8f-bfb9-a749f5da4d68"/></rtd>]]>
		</object>
		<object id="rtds">
			<![CDATA[<rtds><status value="down" syncid="82e7ed95-4ed9-4a8f-bfb9-a749f5da4d68"/></rtds>]]>
		</object>
	</pod>
</ozp>
```

Acknowledgement sent by the server at the application that gave its state. Note the UUID v4 used to identify uniquely the exchange:

```xml
 10 00 00 00 b9 <?xml version="1.0" encoding="utf-8"?><pod><object id="io"><![CDATA[<?xml version="1.0" encoding="utf-8"?><io><ack syncid="82e7ed95-4ed9-4a8f-bfb9-a749f5da4d68"/></io>]]></object></pod>
```
