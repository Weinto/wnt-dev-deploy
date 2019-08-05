#!/bin/bash

# Install DNSMasq
apt-get install -y dnsmasq

# Create a backup of the original configuration
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

# Write new configuration
sudo tee /etc/dnsmasq.conf >/dev/null <<EOF
port=53
address=/${PRIVATE_TLD}/${PRIVATE_IP}
listen-address=${PRIVATE_IP}
addn-hosts=/etc/dnsmasq.hosts
EOF

/etc/dnsmasq.hosts

service dnsmasq restart

# Don't forget to add a resolver to your Host
# On macOS
# sudo tee /etc/resolver/wnt >/dev/null <<EOF
# nameserver 10.192.168.12
# EOF
