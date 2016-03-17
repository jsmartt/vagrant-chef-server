# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w(vagrant-vbguest vagrant-share)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    puts "Installing Vagrant plugin '#{plugin}'..."
    system "vagrant plugin install #{plugin}"
  end
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION ||= '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #====================================================================================
  # Chef Server Package Options:
  # Set to :latest to pull latest versions (doesn't cache packages)
  chef_server_version    = '12.4.1'
  chef_manage_version    = '2.1.2' # Set to nil to skip installation
  chef_reporting_version = '1.5.6' # Set to nil to skip installation
  #====================================================================================

  fail 'ERROR: Must set \'chef_server_version\' variable!' unless defined?(chef_server_version) && !chef_server_version.empty?
  fail 'ERROR: Must set \'chef_manage_version\' variable!' unless defined?(chef_manage_version)
  fail 'ERROR: Must set \'chef_reporting_version\' variable!' unless defined?(chef_reporting_version)

  # config.vm.box = 'nrel/CentOS-6.5-x86_64'
  # config.vm.box = 'bento/centos-6.7'
  config.vm.box = 'bento/centos-7.2'

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  # Accessing "localhost:443" will access port 443 on the guest machine.
  # config.vm.network 'forwarded_port', guest: 443, host: 443
  config.vm.network 'forwarded_port', guest: 443, host: 4433

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network 'public_network'
  # config.vm.network 'public_network', :bridge => 'Intel(R) Ethernet Connection I218-LM'

  name = "test-chef-server-#{chef_server_version}"
  # name = "chef-server-#{ENV['HOSTNAME'] || ENV['USER'] || ENV['USERNAME']}" # TODO: Remove
  config.vm.hostname = 'test-chef-server'
  config.vm.provider 'virtualbox' do |v|
    v.name = name
    v.memory = 2048
  end

  config.vm.provision 'shell', inline: 'rm -f /home/vagrant/chef-server.rb'

  # Copy over the chef-server.rb config file if it exists
  if File.file?('chef-server.rb')
    config.vm.provision 'file', source: 'chef-server.rb', destination: '/home/vagrant/chef-server.rb'
  end

  # Set up networking and firewall
  config.vm.provision 'shell', path: 'scripts/network-setup.sh'

  # Install and configure Chef server components
  arguments = [chef_server_version.to_s, chef_manage_version.to_s, chef_reporting_version.to_s]
  config.vm.provision 'shell', path: 'scripts/install-chef-server.sh', args: arguments

  # Popluate node data by bootstrapping itself
  config.vm.provision 'shell', path: 'scripts/bootstrap-self.sh'

end
