#!/bin/bash

DIR="/tmp/chef-bootstrap-self"

mkdir -p $DIR
cd $DIR
\cp -rf /vagrant/.chef/knife.rb .
\cp -rf /vagrant/.chef/admin.pem .

SEP="\n===================================\n"

echo -e "${SEP}Bootstrapping self (10 times)..."
for i in `seq 1 10`;
do
  echo "${i}:"

  if knife node list | grep -q "^test-chef-server${i}$"; then
    echo "  (Done Already)"
  else
    rm -rf /etc/chef
    knife bootstrap localhost -N test-chef-server$i -x root -P vagrant --bootstrap-no-proxy test-chef-server \
    --no-host-key-verify --no-node-verify-api-cert --node-ssl-verify-mode none > /dev/null
    echo "  DONE!"
  fi
done

echo -e "${SEP}"
