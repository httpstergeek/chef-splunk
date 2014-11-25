# encoding: utf-8
# Cookbook Name:: chef_splunk
# Recipe:: search
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
# Enable Webserver SSL
if node[:splunk][:ssl_options][:enable_ssl]
  ssl_options = node[:splunk][:ssl_options]
  ssl_options[:data_bag_items].each { |key, value|
    cert = ChefVault::Item.load(
      ssl_options[:data_bag],
      value
    )

    files[key] = cert['file-name']
    file "#{splunk_dir}/etc/auth/splunkweb/#{cert['file-name']}" do
      content cert['file-content']
      owner    ssl_options[:owner]
      group    ssl_options[:group]
      mode     ssl_options[:mode]
      notifies :restart, 'service[splunk]'
    end
  }
end

# Configures web.conf for indexer or search
template node[:splunk][:conf_files][:web][:file] do
  source   node[:splunk][:conf_files][:web][:erb]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  mode     node[:splunk][:conf_files][:perms][:mode]
  variables files
  notifies :restart, 'service[splunk]'
end
