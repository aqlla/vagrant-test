# -*- mode: ruby -*-
# vi: set ft=ruby :

require './vagrant.d/default.rb'
require './vagrant.d/kubernetes.rb'

Vagrant.configure("2") do |config|
    config.vm.box = BOX_IMAGE
    config.vm.box_check_update = BOX_CHECK_UPDATE
    config.vm.synced_folder SYNCDIR_HOST, SYNCDIR_GUEST

    # Configure Control-plane Nodes
    (1..node_opt('ctrl', 'count')).each do |i|
        node_ip = get_ip('ctrl', i)
        node_hostname = get_hostname('ctrl', i)

        config.vm.define node_hostname do |node|
            common_config(node, 'ctrl', i, {
                k8s_ctrl_priority: 110 - i,
                k8s_ctrl_state: i == 1? 'MASTER': 'BACKUP',
                k8s_ctrl_state_master: i == 1,              # Depricated
                k8s_ctrl_hosts: get_control_hosts(),
                k8s_vip: {
                    ip: KUBE[:virtual_ip],
                    cidr: KUBE[:virtual_ip_cidr],
                    hostname: KUBE[:virtual_ip_hostname]
                },
                k8s_join_extra_args: [
                    "--control-plane",
                    "--apiserver-advertise-address=#{node_ip}"
                ], 
                k8s_init_extra_args: [
                    "--apiserver-advertise-address=#{node_ip}",
                    "--control-plane-endpoint=#{KUBE[:virtual_ip_hostname]}:#{KUBE[:apiserver_port][:dest]}"
                ]
            })
        end
    end

    # Configure Worker Nodes
    (1..node_opt('work', 'count')).each do |i|
        hostname = get_hostname('work', i)
        config.vm.define hostname do |node|
            common_config(node, 'work', i)
        end
    end
end


###
# Configuration which is common between all nodes. 
#
def common_config(node, role, index, ansible_vars = {})
    node_ip = get_ip(role, index)
    node_hostname = get_hostname(role, index)

    node.vm.hostname = node_hostname
    node.vm.network "public_network", ip: node_ip, bridge: BRIDGE_HOST_IF, hostname: true
    add_bridge_route node, node_ip

    node.vm.provider "virtualbox" do |vb|
        vb.name = node_hostname
        vb.cpus = NCPU
        vb.memory = NMEM

        # keep vbox off our net
        vb.customize ["modifyvm", :id, "--natnet1", NAT_IP_RANGE]
    end

    set_apt_proxy(node, "172.29.0.2", 3142)

    ansible_extra_vars = ansible_vars.merge({
        k8s_role: role,
        k8s_node_if: BRIDGE_CLIENT_IF,
        k8s_node_ip: node_ip,
        k8s_node_host: node_hostname,
        k8s_kubernetes_version: KUBE[:version],
        k8s_config_args: [
            "--cluster-domain=#{KUBE[:cluster_domain]}"
        ]
    })

    node.vm.provision "ansible", run: "once" do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "ansible/pb/test.yml"
        ansible.ask_become_pass = false 
        ansible.extra_vars = ansible_extra_vars
    end
end