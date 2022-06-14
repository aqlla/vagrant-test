# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/jammy64"
NCTRL = 1
NWORK = 2

CMEM = 1024
CCPU = 1

WMEM = CMEM
WCPU = CCPU

HOSTNAME_PREFIX = "it-kube-"
DOMAIN = "acs.sh"

SYNCDIR_HOST = "shared_resources"
SYNCDIR_GUEST = "/home/vagrant/shared_resources"

Vagrant.configure("2") do |config|
  # https://docs.vagrantup.com.
  (1..NCTRL).each do |i|
    config.vm.define HOSTNAME_PREFIX + "m#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = HOSTNAME_PREFIX + "m#{i}." + DOMAIN
      node.vm.network "private_network", ip: "10.0.2.#{10 + i}" #, bridge: "enp6s0"
      node.vm.synced_folder SYNCDIR_HOST, SYNCDIR_GUEST

      node.vm.provider "virtualbox" do |vb|
	vb.name = "it-kube-m#{i}"
	vb.cpus = CCPU
        vb.memory = "#{CMEM}"
      end
    end
  end

  (1..NWORK).each do |i|
    config.vm.define HOSTNAME_PREFIX + "w#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = HOSTNAME_PREFIX + "w#{i}." + DOMAIN
      node.vm.network "private_network", ip: "10.0.2.#{20 + i}" #, bridge: "enp6s0"
      node.vm.synced_folder SYNCDIR_HOST, SYNCDIR_GUEST

      node.vm.provider "virtualbox" do |vb|
	vb.name = HOSTNAME_PREFIX + "w#{i}"
	vb.cpus = WCPU
        vb.memory = "#{WMEM}"
      end
    end
  end
end
