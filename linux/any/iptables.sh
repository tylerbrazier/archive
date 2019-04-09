#!/bin/bash
set -eu

# Script to set up iptables. Make sure iptables.service is enabled.
# For more info, check out https://wiki.archlinux.org/index.php/Iptables


# Reset any existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT


# allow existing connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# accept all traffic from loopback interface (localhost)
iptables -A INPUT -i lo -j ACCEPT

# drop packets with invalid headers, checksums, tcp flags, etc.
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# allow ICMP echo requests (a.k.a pings)
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT

# allow SSH traffic
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# allow http and https web traffic
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# For security, redirect web traffic to higher ports so that web servers can be
# run by unprivileged users who can only listen on ports above 1024.
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8000
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 4430

# also keep the redirection ports open
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
iptables -A INPUT -p tcp --dport 4430 -j ACCEPT

# for general purpose and debugging
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# drop everything else
iptables -A INPUT -j DROP


# persist the changes
mkdir -p /etc/iptables
iptables-save > /etc/iptables/iptables.rules
