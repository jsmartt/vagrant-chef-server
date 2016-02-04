#!/bin/bash

# NOTE: This depends on the following arguments:
#   $1 - String: Chef server core package version (ie '12.3.1')
#   $2 - Boolean: Install Chef Manage? (ie 'true')
#   $3 - Boolean: Install Chef Reporting? (ie 'true')

# Exit on failure
set -e

# Install the stable Chef yum repo
if [ ! -f "/root/chef_repo_installed" ]; then
  echo "Installing Chef-stable yum repo..."
  if curl -s https://packagecloud.io/install/repositories/chef/stable/script.rpm.sh | sudo bash ; then
    touch /root/chef_repo_installed
  fi
else echo "Chef-stable yum repo already installed"
fi

# Copy config file
mkdir -p /etc/opscode
if [ -f "/home/vagrant/chef-server.rb" ]; then
  echo "Updating chef-server.rb config file"
  mv /home/vagrant/chef-server.rb /etc/opscode/chef-server.rb
fi


CHEF_VERSION=$1
MANAGE_VERSION=$2
REPORTING_VERSION=$3
if grep -qi "release 7." /etc/redhat-release ; then OS_VERSION="7"
else OS_VERSION="6"
fi
SEP="\n===================================\n"
STEPS="6"

mkdir -p /vagrant/downloads
cd /vagrant/downloads


# Function to download and install an rpm package
#   Arg1: Package Name
#   Arg2: URL of package to download
download_and_install() {
  _PKG=$1
  _URL=$2
  if [ ! -e "$_PKG" ]; then
    echo "Downloading $_PKG . This may take a while..."
    wget -q $URL --no-check-certificate -O $_PKG
    echo "DONE!"
  fi

  echo "Installing $_PKG"
  rpm -Uvh $_PKG
  echo "DONE!"
}

# Function to reconfigure a component
#   Arg1: Component Name (ie "chef-manage")
reconfigure() {
  _COMPONENT=$1
  echo "Reconfiguring $_COMPONENT..."
  $_COMPONENT-ctl reconfigure > /dev/null
  echo "DONE!"
}


# Install the Chef server
echo -e "${SEP}Step 1/${STEPS}: Install Chef server core"
PKG_NAME="chef-server-core-$CHEF_VERSION-1.el$OS_VERSION.x86_64.rpm"
URL="https://web-dl.packagecloud.io/chef/stable/packages/el/$OS_VERSION/$PKG_NAME"
if which chef-server-ctl > /dev/null 2>&1 ; then echo "(Already installed)"
elif [ "$CHEF_VERSION" = "latest" ] ; then
  yum install -y chef-server-core
  reconfigure "chef-server"
else
  download_and_install $PKG_NAME $URL
  reconfigure "chef-server"
fi


# Install Chef Manage
echo -e "${SEP}Step 2/${STEPS}: Install Chef Manage"
if [ "$MANAGE_VERSION" = "" ] ; then echo "SKIPPED!"
elif which chef-manage-ctl > /dev/null 2>&1 ; then echo "(Already installed)"
elif [ "$MANAGE_VERSION" = "latest" ] ; then
  echo "Installing chef-manage. This may take a while..."
  if chef-server-ctl install opscode-manage || yum install -y chef-manage ; then
    echo "DONE!"
    reconfigure "chef-manage"
  else echo "ERROR INSTALLING chef-manage!"
  fi
else
  PKG_NAME="chef-manage-$MANAGE_VERSION-1.el$OS_VERSION.x86_64.rpm"
  URL="https://web-dl.packagecloud.io/chef/stable/packages/el/$OS_VERSION/$PKG_NAME"
  download_and_install $PKG_NAME $URL
  reconfigure "chef-manage"
fi


# Install Chef Reporting
echo -e "${SEP}Step 3/${STEPS}: Install Chef Reporting"
if [ "$REPORTING_VERSION" = "" ] ; then echo "SKIPPED!"
elif which opscode-reporting-ctl > /dev/null 2>&1 ; then echo "(Already installed)"
elif [ "$REPORTING_VERSION" = "latest" ] ; then
  echo "Installing opscode-reporting. This may take a while..."
  if chef-server-ctl install opscode-reporting || yum install -y opscode-reporting ; then
    echo "DONE!"
    reconfigure "opscode-reporting"
  else echo "ERROR INSTALLING opscode-reporting!"
  fi
else
  PKG_NAME="opscode-reporting-$REPORTING_VERSION-1.el$OS_VERSION.x86_64.rpm"
  URL="https://web-dl.packagecloud.io/chef/stable/packages/el/$OS_VERSION/$PKG_NAME"
  download_and_install $PKG_NAME $URL
  reconfigure "opscode-reporting"
fi


# Configure the server
echo -e "${SEP}Step 4/${STEPS}: Reconfigure the server"
chef-server-ctl reconfigure > /dev/null
echo "DONE!"

# Create a default user
echo -e "${SEP}Step 5/${STEPS}: Create default user 'admin'"
if chef-server-ctl user-list | grep -q "^admin$" ; then
  echo "(Already created)"
else
  chef-server-ctl user-create admin Admin User admin.user@domain.com 'password' -f /vagrant/.chef/admin.pem
  echo "DONE! Private key saved to /vagrant/.chef/admin.pem"
fi

# Create a default organization
echo -e "${SEP}Step 6/${STEPS}: Create default org 'my-org'"
if chef-server-ctl org-list | grep -q "^my-org$" ; then
  echo "(Already created)"
else
  chef-server-ctl org-create my-org "my-org" -a admin -f /vagrant/.chef/my-org-validator.pem
  echo "DONE! Admin user added to org & org validator key saved to /vagrant/.chef/my-org-validator.pem"
fi

echo -e "\n\nServer status:"
chef-server-ctl status || echo "ERROR!"
