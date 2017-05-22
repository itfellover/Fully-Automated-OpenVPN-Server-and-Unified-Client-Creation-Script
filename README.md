# Fully-Automated-OpenVPN-Server-and-Unified-Client-Creation-Script
This script will walk you through quickly deploying an OpenVPN server and creating a Unified client configuration that can be ran easily on many devices like phones for example. 

I've found using a 4096 bit key works without any issues on a phone or any device you choose to run it on, I've given you the option rather than enforce it because some people may feel there is no need for 4096 bit and call it overkill.

This is a hardened configuration of OpenVPN that adds in some features that can cause issues for the user when configuring, whether you use the script or use it as a guide I hope you find it useful.

Some of the features used for hardening are the following:

Prevent a client their certificate to impersonate a server:

remote-cert-eku "TLS Web Client Authentication" <-- This is used on the server
remote-cert-eku "TLS Web Server Authentication" <-- This is used on the client

Setting the minimum TLS version to avoid being downgraded:
tls-version-min 1.2

Strong TLS ciphersuites with:
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256

Static pre-shared key (PSK) shared among all connected clients. This is an additional layer of protection to the TLS channel that ensures all incoming connections are correctly HMAC signed by the PSK key. This could protect your OpenVPN server from DoS attacks aimed at loading your CPU load and helps to avoid fingerpriting:
tls-auth

The use of strong 256 bit symmetric ciphers:
cipher AES-256-CBC

Strong alghoritm for message authentication (HMAC):
auth SHA512

Veririfying the X.509 certificate subject name to make sure the correct certificate is in use:
verify-x509-name

Installing:
sudo apt-get install git

git clone https://github.com/itfellover/Fully-Automated-OpenVPN-Server-and-Unified-Client-Creation-Script.git

cd Fully-Automated-OpenVPN-Server-and-Unified-Client-Creation-Script/

chmod +x OpenVPN_Hardened_Configuration_and_Unified_Client_Creation.sh

sudo ./OpenVPN_Hardened_Configuration_and_Unified_Client_Creation.sh
