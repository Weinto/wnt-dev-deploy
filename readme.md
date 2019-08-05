# Weinto local deployment environment

**wnt-dev-deploy** is a Vagrant virtual machine to provide on a very simple Docker based local deployment.

This virtual machine uses the following elements:


1. [Vagrant](https://www.vagrantup.com/) + Virtualbox and Debian
2. [DNSMasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
3. [Docker](https://docs.docker.com/install/)
4. [Traefik](https://traefik.io/)
5. [Portainer](https://www.portainer.io/) (Not activated by default)

## 1. Vagrant + Virtualbox and Debian

You will need to install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/docs/installation/).

Versions are set in `infrastructure/vagrant/vagrant.dist.json` for consistency across all developpers. However, you can create a copy nammed `vagrant.json` to edit your local settings.

```bash
{
    "node" : 1, # Only one VM is created
    "system" : {
        "box" : "debian/buster64", # Guest OS
        "memory" : 2048, # RAM allowed to this VM
        "cpus" : 1, # CPU allowed
        "gui" : false, # Run a headless VirtualBox VM
        "name" : "wnt-dev-deploy", # Name of your VN
        "hostname" : "wnt-dev-deploy" # Hostname
    },
    "shared_folder" : {
        "host": "default", # ~/vagrant/wnt-dev-deploy
        "guest": "default" # /home/vagrant/data
    },
    "network" : {
        "private_ip" : "10.192.168.12", # Guest private IP. Useful for DNS resolutions.
        "private_tld" : "wnt" # Local TLD. Ex: my-project.wnt
    }
}
```

Then you can start the VM.

### Start & stop

`cd` to the directory where you see the `Vagrantfile`

```bash
vagrant up # Starts the VM

vagrant ssh # SSH access

vagrant halt # Stops the VM
```

## DNSMasq

DNSMasq is running by default and resolves all `*.wnt` to the VM.

- [traefik.wnt](https://traefik.wnt)
- [portainer.wnt](https://traefik.wnt)

However, you will have to add the resolver to your host machine.

Example on macOS

```bash
sudo tee /etc/resolver/wnt >/dev/null <<EOF
nameserver 10.192.168.12
EOF
```

Then you can test with a simple ping

```bash
ping foo.bar.wnt
```

## 3. Docker

Docker installed and readdy for your deployments.

Tip : You can modify `shared_folder` in `vagrant.dist.json` to share a folder from your respositories to the VM. It will be easier to use `docker` commands.

## 4. Traefik

Traefik is a Docker aware reverse proxy.

To launch portainer :

```bash
# From the host machine
vagrant ssh

# From the guest machine
cd /home/vagrant/infrastructure/docker/traefik
docker-compose up -d
```
Now Traefik is up and the dashboard is accessible at [traefik.wnt](https://traefik.wnt)

It is advised to create a `docker-compose.yaml` on your project to connect its container to Traefik.

Example with a simple NGINX container and a PHP app.

> File : `docker-compose.yaml`

```yaml
version: '3'
services:

  app:
    build:
      context: ./
      dockerfile: ./docker/dockerfiles/app.dockerfile
    restart: always
    working_dir: /var/www
    volumes:
      - <YOUR_LOCAL_STORAGE>:/var/www
    networks:
      - private_network
    labels:
      - "traefik.enable=false"

  web:
    image: nginx:latest
    restart: always
    working_dir: /var/www
    volumes:
      - <YOUR_LOCAL_STORAGE>:/var/www
    networks:
      - private_network
      - traefik_network
    labels:
      - "traefik.enabled=true"
      - "traefik.port=80"
      - "traefik.docker.network=traefik_network"
      - "traefik.backend=web"
      - "traefik.frontend.rule=Host:nginx-exemple.wnt"
networks:
  private_network:
    external: false
  traefik_network:
    external: true
```

> File : `app.dockerfile`

```dockerfile
FROM php:7.3.6-fpm-stretch

RUN apt-get update && apt-get install -y libmcrypt-dev \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt

RUN usermod -u 1000 www-data
```

Now you can run it

From the host : `vagrant ssh`
Once you're in the VM : `cd /home/vagrant/data && docker-compose up`

The app will be accessible at [https://nginx-exemple.wnt](https://nginx-exemple.wnt) from your host machine.

## 5. Portainer

Sometimes, it's easier to have a UI to manage Docker.

To launch Portainer :

```bash
# From the host machine
vagrant ssh

# From the guest machine
cd /home/vagrant/infrastructure/docker/portainer
docker-compose up -d
```


Now Portainer is accessible at [portainer.wnt](https://portainer.wnt).