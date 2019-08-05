# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
Vagrant.require_version ">= 2.0.0"

DOCKER_VERSION = "5:19.03.0~3-0~debian-buster"
VAGRANTFILE_API_VERSION = "2"

# Load settings from vagrant.json or vagrant.dist.json
CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
if File.file?("#{CURRENT_DIR}/infrastructure/vagrant/vagrant.json")
    config_file = YAML.load_file("#{CURRENT_DIR}/infrastructure/vagrant/vagrant.json")
else
    config_file = YAML.load_file("#{CURRENT_DIR}/infrastructure/vagrant/vagrant.dist.json")
end
SETTINGS = config_file

# Require plugins

# required_plugins = %w(vagrant-sshfs vagrant-vbguest vagrant-libvirt)
required_plugins = %w(vagrant-sshfs vagrant-vbguest)
required_plugins.each do |plugin|
  need_restart = false
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
  exec "vagrant #{ARGV.join(' ')}" if need_restart
end

def configureVM(vmCfg, hostname, settings)
  vmCfg.vm.box = settings['system']['box']
  vmCfg.vm.communicator = "ssh"
  vmCfg.vm.hostname = hostname
  # https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces
  vmCfg.vm.network "private_network", ip: "#{settings['network']['private_ip']}"

  # Disable project directory default folder sync
  vmCfg.vm.synced_folder '.', '/vagrant', disabled: true

  # sync the developpment host with this Vagrant VM
  srcdir = settings['shared_folder']['host'] === "default" ? "#{ENV["HOME"]}/vagrant/#{hostname}" : settings['shared_folder']['host']
  destdir = settings['shared_folder']['guest'] === "default" ? "/home/vagrant/data" : settings['shared_folder']['guest']
  vmCfg.vm.synced_folder srcdir, destdir, create: true

  vmCfg.vm.synced_folder "./infrastructure/", "/home/vagrant/infrastructure/", create: true


  vmCfg.vm.provider "virtualbox" do |provider, override|
    provider.name = settings['system']['name']
    provider.memory = settings['system']['memory']
    provider.cpus = settings['system']['cpus']
    provider.customize ["modifyvm", :id, "--cableconnected1", "on"]
    provider.gui = settings['system']['gui']

    override.vm.synced_folder srcdir, destdir, type: 'virtualbox', create: true
  end

  # Script to prepare the VM
  vmCfg.vm.provision "shell", path: "#{CURRENT_DIR}/infrastructure/vagrant/install.sh", env: {}
  vmCfg.vm.provision "shell", path: "#{CURRENT_DIR}/infrastructure/vagrant/dnsmasq.sh", env: {"PRIVATE_TLD" => settings['network']['private_tld'], "PRIVATE_IP" => settings['network']['private_ip'] }
  vmCfg.vm.provision "shell", path: "#{CURRENT_DIR}/infrastructure/vagrant/docker.sh", env: {"DOCKER_VERSION" => DOCKER_VERSION}
  vmCfg.vm.provision "shell", path: "#{CURRENT_DIR}/infrastructure/vagrant/traefik.sh"

  vmCfg.vm.post_up_message = <<~HEREDOC
    ------------------------------------------------------
    #{settings['system']['name']}, accessible at #{settings['network']['private_ip']}

    This VM is a local deployment environment based on Docker.

    - DNSMasq
    - Traefik
    - Portainer
    - Docker

    Author: Nicolas Bages <nicolas.bages@weinto.com>
    ------------------------------------------------------
  HEREDOC


  return vmCfg
end

# Entry point of this Vagrantfile
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.auto_update = true
  hostname = "#{SETTINGS['system']['hostname']}"

  config.vm.define hostname do |vmCfg|
    vmCfg = configureVM(vmCfg, hostname, SETTINGS)
  end

end