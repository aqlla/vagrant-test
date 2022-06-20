# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/jammy64"
NCTRL = 1
NWORK = 2

CMEM = 8192
CCPU = 6 
WMEM = CMEM
WCPU = CCPU

HOST_PREFIX = "it-kube"
DOMAIN = "acs.sh"

NAT_IP_RANGE = "10.3/16"
BRIDGED_IP_RANGE = "10.0/24"
NODE_BRIDGE_IP_PREFIX = "10.0.2."

CLIENT_NAT_IF = "enp0s3"
CLIENT_BRIDGE_IF = "enp0s8"

NET_TYPE = "public_network"
NET_BRIDGE_HOST_IF = "br0"

SYNCDIR_HOST = "shared_resources"
SYNCDIR_GUEST = "/home/vagrant/shared_resources"

Vagrant.configure("2") do |config|
  def common_ansible(ansible)
    ansible.verbose = "v"
    ansible.playbook = "test.yml"
    ansible.ask_become_pass = false 
  end

  def add_bridge_route(shell, node_ip)
    shell.inline = "sudo ip route add #{BRIDGED_IP_RANGE} dev #{CLIENT_BRIDGE_IF} proto kernel scope link src #{node_ip}"
  end
  
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = true
  config.vm.synced_folder SYNCDIR_HOST, SYNCDIR_GUEST

  (1..NCTRL).each do |i|
    node_hostname = "#{HOST_PREFIX}-m#{i}"
    node_ip = "#{NODE_BRIDGE_IP_PREFIX}#{10 + i}"
 
    config.vm.define node_hostname do |node|
      node.vm.hostname = "#{node_hostname}.#{DOMAIN}"
      node.vm.network NET_TYPE, ip: node_ip, bridge: NET_BRIDGE_HOST_IF, hostname: true
      node.vm.network "forwarded_port", guest_ip: node_ip, guest: 22, host: "#{2230 + i}", adapter: 2 

      node.vm.provider "virtualbox" do |vb|
        vb.name = node_hostname 
        vb.cpus = CCPU
        vb.memory = CMEM

        vb.customize ["modifyvm", :id, "--natnet1", NAT_IP_RANGE]
      end

      node.vm.provision "shell" do |shell|
        add_bridge_route shell, node_ip
      end

      node.vm.provision "ansible" do |ansible|
        common_ansible ansible

        ansible.extra_vars = {
          k8s_role: "ctrl",
          k8s_node_if: CLIENT_BRIDGE_IF,
          k8s_node_ip: node_ip,
          k8s_node_host: node_hostname
        }
      end
    end
  end

  (1..NWORK).each do |i|
    node_hostname = "#{HOST_PREFIX}-w#{i}"
    node_ip = "#{NODE_BRIDGE_IP_PREFIX}#{20 + i}"

    config.vm.define node_hostname do |node|
      node.vm.hostname = "#{node_hostname}.#{DOMAIN}"
      node.vm.network NET_TYPE, ip: node_ip, bridge: NET_BRIDGE_HOST_IF, hostname: true
      node.vm.network "forwarded_port", guest_ip: node_ip, guest: 22, host: "#{2240 + i}", adapter: 2    
   
      node.vm.provider "virtualbox" do |vb|
        vb.name = node_hostname
        vb.cpus = WCPU
        vb.memory = WMEM
        vb.customize ["modifyvm", :id, "--natnet1", NAT_IP_RANGE]
      end

      node.vm.provision "shell" do |shell|
        add_bridge_route shell, node_ip
      end

      node.vm.provision "ansible" do |ansible|
        common_ansible ansible
        ansible.extra_vars = {
          k8s_role: "worker",
          k8s_node_if: CLIENT_BRIDGE_IF,
          k8s_node_ip: node_ip,
          k8s_node_host: node_hostname
        }
      end
    end
  end
end
