# vagrant-chef-server

This repository contains the Vagrant configurations to quickly spin up a Chef server for testing.


## Dependencies
 - [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 - [Vagrant](https://www.vagrantup.com/downloads.html) and Vagrant plugins:
    - vagrant-share
    - vagrant-vbguest
    - NOTE: Any vagrant command ran inside this repo will install these Vagrant plugins automatically.


## Usage

 1. Clone this repo and then cd into the directory it creates.
 2. Edit the Vagrantfile and modify the "Chef Server Package Options" section (if necessary). For each variable, you may specify one of the following:
  - `nil` - (Manage & Reporting only) Will skip the installation of this add-on
  - `12.4.0` - This will fetch version 12.4.0 and cache the package so it doesn't have to be downloaded again after you destroy the VM. (See the downloads folder in this repo)
  - `:latest` - This will fetch the latest stable version of the package, but will NOT take advantage of caching the package
 4. Run `$ vagrant up` to build the Chef server.
  - This will also create a default user 'admin' with the password 'password' and the org 'my-org'. It also places the user and org keys in the `.chef/` directory of this repo (also accessible to the VM via the `/vagrant/.chef/` shared folder).
 5. Navigate to [https://localhost:4433/login](https://localhost:4433/login) to login to your server!
  - Note that clicking some links may remove the port 4433 from the url; you may have to re-add it when a page is not found.


**NOTE:** This does not upgrade previously installed Chef packages (even if you update the versions in the Vagrantfile). If you want to upgrade the versions on your VM, you can either destroy and re-create it, or `vssh` into the VM and use `yum update <PACKAGE-NAME>` to do so. The package names are: 'chef-server-core', 'chef-manage', and 'opscode-reporting'

**NOTE:** You may also need to add a networking section to the Vagrantfile, but I recommend you do this in your `~/.vagrant.d/Vagrantfile` instead.

## Testing the Server
Each of the Chef components comes with a test command to validate its installation and functionality. It's a good idea to make sure these tests pass on this test system before upgrading real infrastructure.

```bash
$ chef-server-ctl test
$ chef-manage-ctl test
$ opscode-reporting-ctl test
```

## Troubleshooting
 - (Create issues as people run into problems, then fix the bug and create a PR or post solutions here if that's not possible)

## Usefull Links
 - [Chef Server Download Page](https://downloads.chef.io/chef-server/redhat/)
 - [Chef Blog](https://www.chef.io/blog/) - Keep up to date on the latest Chef news & updates
