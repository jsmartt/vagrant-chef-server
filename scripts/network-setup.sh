#!/bin/bash

# Exit on failure
set -e

# Ensure hostname is resolvable
STRING="127.0.0.2   `hostname`"
if ! grep -q "^$STRING$" /etc/hosts; then
  echo "$STRING" | tee -a /etc/hosts && /etc/init.d/network restart
fi


if [ ! -f /etc/sysconfig/iptables ]; then
  touch /etc/sysconfig/iptables
fi

cat > /etc/sysconfig/iptables <<EOL
# File created by Vagrant. Modifying directly is not recommended
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 5672 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOL

if grep -qi "release 7." /etc/redhat-release ; then
  systemctl start iptables || true
  systemctl reload iptables || true
else
  service iptables start
  service iptables reload
fi
