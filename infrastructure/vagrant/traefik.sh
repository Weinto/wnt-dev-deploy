#!/bin/bash

# Create an external network for Traefik
docker network create traefik_network

# Build and mount Traefik container with some settings
cd /home/vagrant/infrastructure/docker/traefik
docker-compose up -d --force-recreate