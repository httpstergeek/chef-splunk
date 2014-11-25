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

# this overrids default attributes for servers running this recipe
node.default[:splunk][:type] = 'indexer'
include_recipe 'chef-splunk::splunk_includes'

# Changes splunk-launch.conf to system managment template.
# Template changes default SPLUNK_DB location.
template node[:splunk][:conf_files][:splunklaunch][:file] do
  source   node[:splunk][:conf_files][:splunklaunch][:erb]
  mode     node[:splunk][:conf_files][:perms][:mode]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  notifies :restart, 'service[splunk]'
  only_if { node[:splunk][:set_db][:enable] }
end

# Template sets deployment client configuration
template node[:splunk][:conf_files][:deployclient][:file] do
  source   node[:splunk][:conf_files][:deployclient][:erb]
  mode     node[:splunk][:conf_files][:perms][:mode]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  notifies :restart, 'service[splunk]'
end
