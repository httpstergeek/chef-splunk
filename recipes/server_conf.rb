# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: indexer
# Author: Bernardo Macias <bmacias84@gmail.com>
#
# All rights reserved - Do Not Redistribute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# set licensing master for search and indexers

files = {}
ssl_options = node[:splunk][:ssl_backend_options]
# set ssl for communications on splunk back-end
if ssl_options[:enable_ssl]
  ssl_options[:data_bag_items].each { |key, value|
    next if key == 'backend_cert_key_pass'
    cert = ChefVault::Item.load(
      ssl_options[:data_bag],
      value
    )

    files[key] = cert['file-name']
    file "#{splunk_dir}/etc/auth/#{cert['file-name']}" do
      content  cert['file-content']
      owner    ssl_options[:owner]
      group    ssl_options[:group]
      mode     ssl_options[:mode]
      notifies :restart, 'service[splunk]'
    end
  }

  if ssl_options[:data_bag_items][:backend_cert_key_pass]
    keypass = ChefVault::Item.load(
      ssl_options[:data_bag],
      ssl_options[:data_bag_items][:backend_cert_key_pass]
    )
    keyvalue = keypass['file-content']
  end
else
  keypass = ChefVault::Item.load(
    ssl_options[:data_bag],
    'splunk_sslconfpass_default'
  )
  keyvalue = keypass['file-content']
end

# enables search head pooling with  nfs mount point and sets license master
template node[:splunk][:conf_files][:server][:file] do
  source    node[:splunk][:conf_files][:server][:erb]
  owner     node[:splunk][:conf_files][:perms][:owner]
  group     node[:splunk][:conf_files][:perms][:group]
  mode      node[:splunk][:conf_files][:perms][:mode]
  variables backend_cert: files['backend_cert'], backend_ca_cert: files['backend_ca_cert'], keyvalue: keyvalue
  notifies  :restart, 'service[splunk]'
  not_if { node[:splunk][:type] == 'searchpool' }
end

# set ui-prefs.conf for search heads.
template node[:splunk][:conf_files][:server][:file] do
  source    node[:splunk][:conf_files][:server][:erb]
  owner     node[:splunk][:conf_files][:perms][:owner]
  group     node[:splunk][:conf_files][:perms][:group]
  mode      node[:splunk][:conf_files][:perms][:mode]
  notifies  :restart, 'service[splunk]'
end
