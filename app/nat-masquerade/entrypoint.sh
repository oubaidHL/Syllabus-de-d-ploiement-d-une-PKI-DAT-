#!/bin/bash

# Enable IPv4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Disable IPv6 completely
echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6

# Flush existing rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Allow all loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-reply -j ACCEPT

# Masquerade rules
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

# Port forwarding rules
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 192.168.2.10:53
iptables -t nat -A PREROUTING -i eth1 -p udp --dport 53 -j DNAT --to-destination 192.168.2.10:53

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9000 -j DNAT --to-destination 192.168.2.2:9000
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 9000 -j DNAT --to-destination 192.168.2.2:9000

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9001 -j DNAT --to-destination 192.168.2.3:9000
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 9001 -j DNAT --to-destination 192.168.2.3:9000

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.3.11:80
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.3.11:80

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 192.168.3.11:443
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j DNAT --to-destination 192.168.3.11:443

# Keep container running
tail -f /dev/null