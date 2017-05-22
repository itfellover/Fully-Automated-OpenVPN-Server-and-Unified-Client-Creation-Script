#!/bin/bash

echo "
#######                      #     # ######  #     #
#     # #####  ###### #    # #     # #     # ##    #
#     # #    # #      ##   # #     # #     # # #   #
#     # #    # #####  # #  # #     # ######  #  #  #
#     # #####  #      #  # #  #   #  #       #   # #
#     # #      #      #   ##   # #   #       #    ##
####### #      ###### #    #    #    #       #     #

#     #
#     #   ##   #####  #####  ###### #    # ###### #####
#     #  #  #  #    # #    # #      ##   # #      #    #
####### #    # #    # #    # #####  # #  # #####  #    #
#     # ###### #####  #    # #      #  # # #      #    #
#     # #    # #   #  #    # #      #   ## #      #    #
#     # #    # #    # #####  ###### #    # ###### #####

 #####
#     #  ####  #####  # #####  #####
#       #    # #    # # #    #   #
 #####  #      #    # # #    #   #
      # #      #####  # #####    #
#     # #    # #   #  # #        #
 #####   ####  #    # # #        #
+-+-+ +-+-+-+-+-+-+-+-+-+-+
|b|y| |I|T|F|e|l|l|o|v|e|r|
+-+-+ +-+-+-+-+-+-+-+-+-+-+
https://www.itfellover.com
"

echo "First you need to feed in some details required for the script to complete "
echo "First 2048 Bit or 4096 Bit? I highly recommend 4096 Bit as you won't notice any difference in speed:"
read Bits

echo "What port do you want to use? I recommend 443 as it's usually allowed out on most networks"
read port

echo "Now you need to enter your cert details, what would you like to enter?"
echo "You can enter anything you want in these fields, check out the example below:"

echo 'KEY_COUNTRY="IE" <-- This is your country'
echo 'KEY_PROVINCE="DU" <-- This is your province/state'
echo 'KEY_CITY="Dublin" <-- This is your city'
echo 'KEY_ORG="The ORG" <-- This is your organisation'
echo 'KEY_EMAIL="me@mymail.com" <-- This is your email address'
echo 'KEY_OU="MYU" <-- This is your organisational unit'
echo 'KEY_NAME="server" <-- This is the name you want to call your server'

echo "Enter the country"
read Country
echo "Enter the province"
read Province
echo "Enter the City"
read City
echo "Enter an organisation"
read Org
echo "Enter an email address"
read Email
echo "Enter an organisational unit"
read Ounit
echo "Enter a name for the server"
read Server

echo "Enter a client name to generate an ovpn file on completion so you can quickly test it"
read Client

echo "What user account would you like to copy the output files to? Eg. The standard account you are using currently"
read usaccount

IPADDR=$(curl icanhazip.com)
apt-get update && apt-get upgrade -y && apt-get install openvpn easy-rsa -y


echo 'remote-cert-eku "TLS Web Client Authentication"'  >> /etc/openvpn/"$Server".conf
echo "tls-version-min 1.2"  >> /etc/openvpn/"$Server".conf
echo "tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256"  >> /etc/openvpn/"$Server".conf
echo "max-clients 10"  >> /etc/openvpn/"$Server".conf
echo "log-append /var/log/openvpn.log"  >> /etc/openvpn/"$Server".conf
echo "port" "$port"  >> /etc/openvpn/"$Server".conf
echo "proto tcp"  >> /etc/openvpn/"$Server".conf
echo "dev tun"  >> /etc/openvpn/"$Server".conf
echo "ca ca.crt"  >> /etc/openvpn/"$Server".conf
echo "cert "$Server".crt"  >> /etc/openvpn/"$Server".conf
echo "key "$Server".key"  >> /etc/openvpn/"$Server".conf
echo "dh" "dh""$Bits"".pem"   >> /etc/openvpn/"$Server".conf
echo "server 10.8.0.0 255.255.255.0"  >> /etc/openvpn/"$Server".conf
echo "ifconfig-pool-persist ipp.txt"  >> /etc/openvpn/"$Server".conf
echo 'push "redirect-gateway def1 bypass-dhcp"'  >> /etc/openvpn/"$Server".conf
echo 'push "dhcp-option DNS 208.67.222.222"'  >> /etc/openvpn/"$Server".conf
echo 'push "dhcp-option DNS 208.67.220.220"'  >> /etc/openvpn/"$Server".conf
echo "keepalive 10 120"  >> /etc/openvpn/"$Server".conf
echo "tls-auth ta.key 0"  >> /etc/openvpn/"$Server".conf
echo "cipher AES-256-CBC"  >> /etc/openvpn/"$Server".conf
echo "auth SHA512"  >> /etc/openvpn/"$Server".conf
echo "comp-lzo"  >> /etc/openvpn/"$Server".conf
echo "user nobody"  >> /etc/openvpn/"$Server".conf
echo "group nogroup"  >> /etc/openvpn/"$Server".conf
echo "persist-key"  >> /etc/openvpn/"$Server".conf
echo "persist-tun"  >> /etc/openvpn/"$Server".conf
echo "status openvpn-status.log"  >> /etc/openvpn/"$Server".conf
echo "verb 3"  >> /etc/openvpn/"$Server".conf

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf
apt-get install ufw -y
ufw allow ssh
ufw allow "$port"/tcp
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|g' /etc/default/ufw
sed -i "1i# START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from OpenVPN client to eth0\n\n-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES\n" /etc/ufw/before.rules
ufw --force enable
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys

sed -i 's|US|'"$Country"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|CA|'"$Province"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|SanFrancisco|'"$City"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|Fort-Funston|'"$Org"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|me@myhost.mydomain|'"$Email"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|MyOrganizationalUnit|'"$Ounit"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|EasyRSA|'"$Server"'|g' /etc/openvpn/easy-rsa/vars
sed -i 's|2048|'"$Bits"'|g' /etc/openvpn/easy-rsa/vars

openssl dhparam -out /etc/openvpn/dh"$Bits".pem "$Bits"

cd /etc/openvpn/easy-rsa
. ./vars # Error Here but it still worked
./clean-all
./build-ca --batch
./build-key-server --batch "$Server"
./build-dh
openvpn --genkey --secret keys/ta.key
cp /etc/openvpn/easy-rsa/keys/{"$Server".crt,"$Server".key,ca.crt,ta.key} /etc/openvpn
ls /etc/openvpn
service openvpn start
service openvpn status
./build-key --batch "$Client"

echo 'remote-cert-eku "TLS Web Server Authentication"'  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "verify-x509-name 'C="$Country", ST="$Province", L="$City", O="$Org", OU="$Ounit", CN="$Server", name="$Server", emailAddress="$Email"'"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "tls-version-min 1.2"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "client" >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "dev tun"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "proto tcp"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "remote" "$IPADDR" "$port"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "resolv-retry infinite" >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "nobind" >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "user nobody"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "group nogroup"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "persist-key"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "persist-tun"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "ns-cert-type server" >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "cipher AES-256-CBC"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "auth SHA512"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "key-direction 1"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "comp-lzo"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo "verb 3"  >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn

echo '<ca>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
cat /etc/openvpn/easy-rsa/keys/ca.crt >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo '</ca>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn

echo '<cert>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
cat /etc/openvpn/easy-rsa/keys/"$Client".crt >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo '</cert>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn

echo '<key>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
cat /etc/openvpn/easy-rsa/keys/"$Client".key >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo '</key>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn

echo '<tls-auth>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
cat /etc/openvpn/easy-rsa/keys/ta.key >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn
echo '</tls-auth>' >> /etc/openvpn/easy-rsa/keys/"$Client".ovpn

mkdir /home/"$usaccount"/OpenVPN_Config_"$Client"
cp /etc/openvpn/easy-rsa/keys/"$Client".crt /home/"$usaccount"/OpenVPN_Config_"$Client"
cp /etc/openvpn/easy-rsa/keys/"$Client".key /home/"$usaccount"/OpenVPN_Config_"$Client"
cp /etc/openvpn/easy-rsa/keys/ta.key /home/"$usaccount"/OpenVPN_Config_"$Client"
cp /etc/openvpn/easy-rsa/keys/"$Client".ovpn /home/"$usaccount"/OpenVPN_Config_"$Client"
cp /etc/openvpn/ca.crt /home/"$usaccount"/OpenVPN_Config_"$Client"
cd /home/"$usaccount"/OpenVPN_Config_"$Client"

echo "Copy client.ovpn to your local system"
echo "scp -r $usaccount@$IPADDR:/home/"$usaccount"/OpenVPN_Config_"$Client"/"$Client".ovpn ."







