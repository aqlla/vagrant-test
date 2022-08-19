BOX_IMAGE = "ubuntu/jammy64"
BOX_CHECK_UPDATE = false 

SYNCDIR_HOST = "shared_resources"
SYNCDIR_GUEST = "/mnt/shared_resources"

DOMAIN = "acs.sh"
HOST_PREFIX_PREFIX = "it-kube"
NODE_IP_PREFIX = "10.0.2"

BRIDGE_CLIENT_IF = "enp0s8"
BRIDGE_HOST_IF = "enp5s0"
BRIDGE_NET_CIDR = "22"
BRIDGE_IP_RANGE = "10.0.0.0/#{BRIDGE_NET_CIDR}"
GATEWAY_ADDR = "10.0.0.1"
NAT_IP_RANGE = "10.3/16"

NCPU = 3
NMEM = 8192


def set_apt_proxy(cfg, proxy_host, proxy_port)
    cfg.vm.provision "shell", run: "once", inline: <<-SHELL
        cat <<EOF >> /etc/apt/apt.conf.d/proxy 
Acquire {
    http::proxy  "http://#{proxy_host}:#{proxy_port}";
    https::proxy "http://#{proxy_host}:#{proxy_port}";
    ftp::proxy   "http://#{proxy_host}:#{proxy_port}";
}
EOF
SHELL
end


def add_bridge_route(node, node_ip)
    node.vm.provision "shell", run: "once", inline: <<-SHELL
        sudo ip route add #{BRIDGE_IP_RANGE} dev #{BRIDGE_CLIENT_IF} proto kernel scope link src #{node_ip};
        sudo ip route add default via #{GATEWAY_ADDR} dev #{BRIDGE_CLIENT_IF} src #{node_ip};
        
        sudo ip route add 172/8 dev #{BRIDGE_CLIENT_IF} proto kernel scope link src #{node_ip};
        sudo ip route add 172.29/16 via 172.29.0.1 dev #{BRIDGE_CLIENT_IF} proto static;
        # sudo ip route add 172.29/16 via 172.29.0.1 dev enp0s8 proto static;
SHELL
end