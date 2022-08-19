# -*- mode: ruby -*-
# vi: set ft=ruby :

require './vagrant.d/default.rb'


KUBE = {
    "version": '1.24.2',
    "cluster_domain": "kube.#{DOMAIN}",
    "virtual_ip": "#{NODE_IP_PREFIX}.100",
    "virtual_ip_cidr": BRIDGE_NET_CIDR,
    "virtual_ip_hostname": "lb.kube.#{DOMAIN}",

    "apiserver_port": {
        "src": 6443,
        "dest": 8443
    },

    "nodes": {
        "ctrl": {
            "host_prefix": "#{HOST_PREFIX_PREFIX}-m",
            "start_ip": 10,
            "count": 3,
            "role": "ctrl"
        },
        "work": {
            "host_prefix": "#{HOST_PREFIX_PREFIX}-w",
            "start_ip": 20,
            "count": 3,
            "role": "worker"
        }
    }
}




# KUBERNETES 
 
# Returns a list of control-plane nodes for haproxy and keepalived.
# Items are strings containing hostname and ip, separated by a space.
# i.e.: host.example.com 5.6.4.3
#
def get_control_hosts()
    opts = KUBE[:nodes][:ctrl]
    return (1..opts[:count]).map { 
        |i| "#{opts[:host_prefix]}#{i} #{NODE_IP_PREFIX}.#{opts[:start_ip] + i}" 
    }
end

def node_opt(role, key)
    return KUBE[:nodes][:"#{role}"][:"#{key}"]
end

def get_hostname(role, index)
  prefix = KUBE[:nodes][:"#{role}"][:host_prefix]
  return "#{prefix}#{index}"
end

def get_ip(role, index)
  return "#{NODE_IP_PREFIX}.#{KUBE[:nodes][:"#{role}"][:start_ip] + index}"
end