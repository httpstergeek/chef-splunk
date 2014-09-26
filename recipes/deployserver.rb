# encoding: utf-8
# Cookbook Name:: splunk
# Recipe:: deployserver
# Author: Bernardo Macias <bmacias@httpstergeek.com>
#
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
node.default[:splunk][:type] = 'deployserver'
include_recipe 'chef-splunk::splunk_includes'

template node[:splunk][:conf_files][:serverclass][:file] do
  source   node[:splunk][:conf_files][:serverclass][:erb]
  mode     node[:splunk][:conf_files][:perms][:mode]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  notifies :restart, 'service[splunk]'
end

template node[:splunk][:iptables][:iptable_tgt] do
  source node[:splunk][:iptables][:iptable_src]
  mode   '0600'
  owner  'root'
  group  'root'
  variables(
    resource: self
  )
  only_if { node[:splunk][:iptables][:redirect] }
end

service 'iptables' do
  supports restart: true, reload: true, status: true
  action :start
  subscribes :reload, 'template[node[:splunk][:iptables][:iptable_tgt]]', :immediately
  only_if { node[:splunk][:iptables][:redirect] }
end
