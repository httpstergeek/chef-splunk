# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: inputs_conf
# Author: Bernardo Macias <bmacias84@gmail.com>
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

files = {}
# configures indexer(receiver) for ssl
if node[:splunk][:receiver_options][:splunktcp_ssl][:enable_splunktcp_ssl]
  splunktcp_ssl = node[:splunk][:reciever_options][:splunktcp_ssl]
  splunktcp_ssl[:data_bag_items].each { |key, value|
    certs = ChefVault::Item.load(
      splunktcp_ssl[:data_bag],
      value
    )

    files[keys] = cert['file-name']
    file "#{splunk_dir}/etc/auth/#{cert['file-name']}" do
      content certs['file-content']
      owner    node[:splunk][:conf_files][:perms][:owner]
      group    node[:splunk][:conf_files][:perms][:group]
      mode     node[:splunk][:conf_files][:perms][:mode]
      notifies :restart, 'service[splunk]'
    end
  }
end

# template sets indexer recieving ports
template node[:splunk][:conf_files][:inputs][:file] do
  source    node[:splunk][:conf_files][:inputs][:erb]
  owner     node[:splunk][:conf_files][:perms][:owner]
  group     node[:splunk][:conf_files][:perms][:group]
  mode      node[:splunk][:conf_files][:perms][:mode]
  variables files
  notifies :restart, 'service[splunk]'
end
