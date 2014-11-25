# default.rb Example                                      
Below is an example of a default.rb file                  
                                                          
                                                          
```ruby                                                   
# encoding: utf-8                                         
# Cookbook Name:: chef-splunk                        
# Attributes:: default                                    
#                                                         
#                                                         
# All rights reserved - Do Not Redistribute               
                                                          
# Assume default use case is a Splunk Server (NOT client).

# encoding: utf-8   
# Cookbook Name:: chef-splunk
# Attributes:: default
#
#
# All rights reserved - Do Not Redistribute

# Assume default use case is a Splunk Server (NOT client).
default[:chef_vault][:version] = '2.2.0'
default[:chef_vault][:source] = '--clear-sources --source http://rubygems.org'
default[:splunk][:install_git] = false
default[:splunk][:is_server] = true
default[:splunk][:accept_license] = true
default[:splunk][:type] = nil
default[:splunk][:set_db] = {      
  enable: false,                   
  path:   '/opt/splunk/mnt/index01'
}                                  

default[:splunk][:mgmt_port] = '8089'
default[:splunk][:license_uri] = 'master'
default[:splunk][:bypass_auth] = false

default[:splunk][:secret] = {
  data_bag:       'vault',
  data_bag_item:  'splunk_secret_prod',
  file:  'splunk.secret'
}

default[:splunk][:passwd] = {
  data_bag:       'vault',
  data_bag_item:  'splunk_passwd_prod',
  file:           'passwd'
}

default[:splunk][:ui_prefs][:enable] = {
  enable: false,
  dispatch_etime: '-15m',
  dispatch_ltime: 'now',
  search_mode: 'fast'
}

default[:splunk][:distsearch] = {
  enable_distsearch: true,
  share_bundles:   false,
  search_peers: %w{33.33.33.11 33.33.33.25},
  mounted_bundles: true,
  search_bundles:  [
    {
      search_heads:    %w{33.33.33.12 33.33.33.18},
      bundle_location: {
        nfs_device:       '33.33.33.13:/mnt/search_head_pooling',
        mount_location:   '/mnt/search_head_pooling/ga',
        symlink_location: '/opt/shared_bundles/ga'
      }
    },
  ]
}

default[:splunk][:searchpool] = {
  enable_pool:      'enabled',
  pool_server:      '33.33.33.13',
  pool_mnt:         '/mnt/search_head_pooling',
  symlink_location: '/opt/search_head_pooling',
  network:          '*',
}

default[:splunk][:deployment_options] = {
  deployment_uri: 'splunkdeploy.net',
  phonehome:      '300'
}

default[:splunk][:webserver_options] = {
  port:               '443',
  update_checker_url: '0'
}

default[:splunk][:ssl_options] = {
  enable_ssl:    true,
  data_bag:      'vault',
  data_bag_items: {
    webserver_cert: 'splunk_webcert_sandbox',
    webserver_key:  'splunk_webkey_sandbox'
  },
  mode:          0660,
  owner:         'splunk',
  group:         'splunk'
}

default[:splunk][:ssl_backend_options] = {
  enable_ssl:    false,
  data_bag:      'vault',
  data_bag_items: {
    backend_cert: 'splunk_apicert_sandbox',
    backend_ca_cert: 'splunk_cacert_sandbox',
    backend_cert_key_pass: 'splunk_apicertkeypass_sandbox'
  },
  mode:          0660,
  owner:         'splunk',
  group:         'splunk'
}

default[:splunk][:receiver_options] = {
  splunktcp_ssl: {
    enable_splunktcp_ssl: false,
    data_bag:             'vault',
    data_bag_items: {
      root_ca:              'splunk_recrootca_sandbox',
      server_cert:          'splunk_recservercert_sandbox',
    },
    port:                 '9998',
    mode:                 0660,
    owner:                'splunk',
    group:                'splunk',
  },
  splunktcp: {
    enable_splunktcp: true,
    port:             '9997'
  },
  udp: {
    enable_udp: false,
    ports:    %w{256}
  },
  tcp: {
    enable_tcp: false,
    ports:      %w{514 80 4589}
  }
}

default[:splunk][:user] = {
  username: 'splunk',
  comment:  'Splunk Server',
  home:     '/opt/splunkforwarder',
  shell:    '/bin/bash',
  uid:       396,
}

if node[:splunk][:is_server]
  default[:splunk][:user][:home] = '/opt/splunk'
end

splunk_system = "#{splunk_dir}/etc/system/local"

default[:splunk][:dir_perms] = {
  mode:  0775,
  owner: 'splunk',
  group: 'splunk'
}

default[:splunk][:conf_files] = {
  serverclass: {
    file: "#{splunk_system}/serverclass.conf",
    erb:  'system-serverclass.conf.erb'
  },
  splunklaunch: {
    file: "#{splunk_dir}/etc/splunk-launch.conf",
    erb: 'system-splunk-launch.conf.erb'
  },
  server: {
    file: "#{splunk_system}/server.conf",
    erb: 'system-server.conf.erb'
  },
  deployclient: {
    file: "#{splunk_system}/deploymentclient.conf",
    erb:  'system-deploymentclient.conf.erb'
  },
  inputs: {
    file: "#{splunk_system}/inputs.conf",
    erb: 'system-inputs.conf.erb'
  },
  web: {
    file: "#{splunk_system}/web.conf",
    erb:  'system-web.conf.erb'
  },
  distsearch: {
    file: "#{splunk_system}/distsearch.conf",
    erb:  'system-distsearch.conf.erb',
  },
  outputs: {
    file: "#{splunk_system}/outputs.conf",
    erb:  'system-outputs.conf.erb',
  },
  ui_prefs: {
    file:  "#{splunk_system}/ui_prefs.conf",
    erb:   'system-ui_refs.conf.erb'
  },
  perms: {
    mode:  0664,
    owner: 'root',
    group: 'root'
  }
}
```
