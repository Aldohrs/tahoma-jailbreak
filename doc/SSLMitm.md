# Setting up a Man-In-The-Middle connection with the TaHoma

When following the steps described in [Jailbreak.md](./Jailbreak.md), you can edit the firmware to configure it for MITM or custom servers.

To redirect the traffic from the TaHoma you have 2 options:

* Edit the `/etc/hosts` file in the TaHoma firmware
* Install a lying DNS server on the network (like Responder)

You'll find plenty of tutorials for both approaches. In both cases you'll need to point the following domains to an IP address you own (like a Raspberry Pi):

* upgrade.overkiz.com
* ha101-3.overkiz.com (there may be other domains for this one for load balancing purposes)

Once your TaHoma is configured to call custom IPs, you'll need to provide it with custom certificates to make sure that it is able to communicate with your custom server.

Check the script located in [scripts/mitm-certificate/](../scripts/mitm-certificate/). It will generate all the needed certificates and keys to build a complete chain of trust.

On the TaHoma side you'll need to replace, in the security volume, the client certificate and key files aswell as the server CA certificate by the certificates generated. Make sure to keep the same names.

Note that if you want to preserve the hostname, you will have to modify the `client.crt` to include the certificate as text (from Certificate: to the end of the signature) and edit it to remove the spaces aroud the '=' sign in `CN = XXXX-XXXX-XXXX`.

To get the certificate as text, issue the following command:

```
openssl x509 -text -in client.crt
```

On the other side, you'll need to set up a nginx server with the server CA certificate, the client CA certificate and the wildcard certificate and key. Here is an example of configuration file for nginx that allows the request to be forwarded to an HTTP application that runs locally:

```
server {
    listen 443 ssl;
    
    error_log   /var/log/nginx-error.log;
    access_log  /var/log/nginx-access.log; # Useful for debug

    # Replace the paths here with the actual paths to your certificates
    ssl_certificate          /etc/ssl/rogue-certs/server.pem; # Wildcard certificate
    ssl_certificate_key      /etc/ssl/rogue-certs/server.key; # Wildcard certificate key
    ssl_trusted_certificate  /etc/ssl/rogue-certs/ca.pem; # Server CA certificate
    ssl_client_certificate   /etc/ssl/rogue-certs/client-ca.pem; # Client CA certificate
    ssl_verify_client        on; # If you have issues with client certificate validation, disable that

    server_name ha-upgrade.overkiz.com; # An identical file should be made for each domain. That allows to simulate different hosts. It could also be useful forSNI

    location / {
        proxy_pass http://127.0.0.1:8000; # Your backend web application, for first attempts this could be a python HTTP server or Responder. But to have a full analysis of the API, a custom server must be developed.
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

As you see, at the moment, you still need to provide yourself a backend server. It will allow to have the information about requests sent by the TaHoma. A quickcheck to ensure everything is okay is to run an HTTP python server (`python3 -m http.server 8000`) and look for incoming requests from the TaHoma when plugged in.

If you have no incoming request, check the date of the TaHoma. As the box has no Real Time Clock, it expects a date from the DHCP server or a NTP server (on ha-ntp.overkiz.com) at startup.
