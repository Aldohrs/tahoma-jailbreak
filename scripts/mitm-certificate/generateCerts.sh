#!/bin/bash

if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <key_length> <pod-serial>"
        exit;
fi

echo "Generating a $1 bits long CA certificate for servers"
openssl req -config server-ca.conf -keyform PEM -keyout server-ca.key -x509 -days 3650 -outform PEM -out server-ca.pem -extensions v3_ca
openssl rsa -in server-ca.key -passin pass:password -out server-ca.key
echo "Generating a $1 bits long wildcard server certificate and signing it with the CA..."
openssl genrsa -passout pass:password -out wildcard.key $1
openssl req -new -keyform PEM -passin pass:password -key wildcard.key -out wildcard.req -config wildcard.conf
openssl rsa -in wildcard.key -passin pass:password -out wildcard.key
openssl x509 -req -in wildcard.req -CA server-ca.pem -CAkey server-ca.key -set_serial 100 -days 1460 -extfile wildcardext.conf -outform PEM -out wildcard.pem
echo "Generating a $1 bits long CA certificate for gateway devices"
openssl req -config client-ca.conf -keyform PEM -keyout client-ca.key -x509 -days 3650 -outform PEM -out client-ca.pem -extensions v3_ca
openssl rsa -in client-ca.key -passin pass:password -out client-ca.key
echo "Generating a client certificate (at last!)"
openssl genrsa -passout pass:password -out client.key $1
openssl req -new -keyform PEM -passin pass:password -key client.key -out client.req -config client.conf -subj "/O=Overkiz/OU=Gateway Device/CN=$2"
openssl rsa -in client.key -passin pass:password -out client.key
openssl x509 -req -in client.req -CA client-ca.pem -CAkey client-ca.key -set_serial 100 -days 1460 -extfile clientext.conf -outform PEM -out client.pem
echo ""
echo ""
openssl x509 -text -noout -in client.pem
echo ""
echo ""
echo "Cleaning..."
rm client.req wildcard.req
echo "You certificate files are as following:"
echo "No key is password-protected. Keys are provided for each cert"
echo "* Server CA: certificate authority to sign the server certificate. The certificate should be provided as CA for the TaHoma under /etc/security and to the server in the trust chain"
echo "* Client CA: certificate authority to sign the client certificates. The certificate should be provided to the web server as trusted certificate for client authentication"
echo "* Wildcard certificate. The certificate and its private key should be configured on the server. The same certificate can be used for multiple subdomains"
echo "* Client certificate. The certificate and the private key should be specified in /etc/security on the client side"
echo "If you want to keep the hostname clean in your TaHoma, you should copy the full certificate information above (from Certificate: to the end of the signature) and edit it to remove the spaces aroud the '=' sign in CN = $2"
