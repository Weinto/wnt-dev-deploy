#!/bin/bash

# Update apt and get dependencies

sudo apt-get -y update
sudo apt-mark hold grub
sudo apt-mark hold grub-pc
sudo apt-get -y upgrade
sudo apt-get install -y \
    zip \
    unzip \
    curl \
    wget \
    git \
    vim\
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    net-tools \
    dnsutils \
    iputils-ping
#sudo apt-get install -y socat ebtables
