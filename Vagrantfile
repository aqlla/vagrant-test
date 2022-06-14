# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/jammy64"
NCTRL = 1
NWORK = 2

Vagrant.configure("2") do |config|
  # https://docs.vagrantup.com.
  (1..NCTRL).each do |i|
    config.vm.define "it-kube-m#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = "it-kube-m#{i}.acs.sh"     
      node.vm.network "private_network", ip: "10.0.2.#{10 + i}", bridge: "enp6s0"
      node.vm.synced_folder "./shared_resources", "/home/vagrant/shared_resources"

      node.vm.provider "virtualbox" do |vb|
	    vb.name = "it-kube-m#{i}"
	    vb.cpus = 2
        vb.memory = "4096"
      end
    end
  end

  (1..NWORK).each do |i|
    config.vm.define "it-kube-w#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = "it-kube-w#{i}.acs.sh"     
      node.vm.network "private_network", ip: "10.0.2.#{20 + i}", bridge: "enp6s0"
      node.vm.synced_folder "./shared_resources", "/home/vagrant/shared_resources"

      node.vm.provider "virtualbox" do |vb|
	    vb.name = "it-kube-w#{i}"
	    vb.cpus = 2
        vb.memory = "4096"
      end
    end
  end
end
