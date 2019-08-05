#!/bin/bash

cd traefik
docker-compose up -d --force-recreate --build

cd ..

cd portainer
docker-compose up -d --force-recreate --build