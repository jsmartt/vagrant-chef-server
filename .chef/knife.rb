# See https://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   "my-org-validator"
validation_key           "#{current_dir}/my-org-validator.pem"
chef_server_url          "https://test-chef-server/organizations/my-org"

verify_api_cert false
ssl_verify_mode :verify_none
no_proxy 'localhost, test-chef-server'
