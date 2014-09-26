# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: indexer
# Author: Bernardo Macias <bmacias@httpstergeek.com>
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

execute 'copy_server_conf'  do
  command  "cp  #{node[:splunk][:conf_files][:server][:file]} #{node[:splunk][:conf_files][:server][:file]}.orig"
  only_if { ::File.exist?(node[:splunk][:conf_files][:server][:file]) }
  not_if { ::File.exist?("#{node[:splunk][:conf_files][:server][:file]}.orig") }
end

# enables search head pooling with  nfs mount point and sets license master
template node[:splunk][:conf_files][:server][:file] do
  source    node[:splunk][:conf_files][:server][:erb]
  owner     node[:splunk][:conf_files][:perms][:owner]
  group     node[:splunk][:conf_files][:perms][:group]
  mode      node[:splunk][:conf_files][:perms][:mode]
  variables included_file: "#{node[:splunk][:conf_files][:server][:file]}.orig"
  notifies  :restart, 'service[splunk]'
  not_if { node[:splunk][:type] == 'searchpool' }
end
