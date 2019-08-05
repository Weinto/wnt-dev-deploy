#!/bin/bash

# Source : https://docs.docker.com/install/linux/docker-ce/debian/

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# Set up the stable repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Update package index
apt-get update

# Install a fixed version of Docker Engine - Community and containerd for consitency purposes over all developpers
apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io

# Allow vagrant to manipulate Docker
usermod -aG docker vagrant

# Start Docker on boot
systemctl enable docker

# Download docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
chmod +x /usr/local/bin/docker-compose

# Add it to user/bin
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose