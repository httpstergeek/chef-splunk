# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: splunk_includes
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

# stop iptables/firewall in vagrant env.
service 'iptables' do
  supports :status => true, :start => true, :stop => true, :restart => true
  provider Chef::Provider::Service::Init
  action   :stop
  only_if { Chef::Config[:solo] }
end

chef_gem 'chef-vault' do
  version node[:chef_vault][:version]
  options node[:chef_vault][:source]
end

require 'chef-vault'

# installs git, Splunk administrator should be git to manage deployment apps 
yum_package 'git' do
  action :install
  only_if { node[:splunk][:install_git] }
end

if %w{indexer searchpool}.include?(node[:splunk][:type])
  node.default[:nix_server][:first_directories].merge!(node[:splunk][:disk][:first_directories]) if node[:splunk][:type] == 'indexer'
  node.default[:nix_server][:volume_groups].merge!(node[:splunk][:disk][node[:splunk][:type]][:volume_groups])
  node.default[:nix_server][:lvmvols].merge!(node[:splunk][:disk][node[:splunk][:type]][:lvmvols])
end

# Recipe used store all common includes
include_recipe 'java'
include_recipe 'tuned' if %w{indexer search searchpool}.include?(node[:splunk][:type])
include_recipe 'chef-splunk::user' if Chef::Config[:solo]
#include_recipe 'chef-splunk::upgrade'
include_recipe 'chef-splunk::install_server'
include_recipe 'chef-splunk::splunk_secrets' unless node[:splunk][:bypass_auth]
include_recipe 'chef-splunk::service'
include_recipe 'chef-splunk::web_conf'
include_recipe 'chef-splunk::server_conf' unless node[:splunk][:type] == 'imforwarder'
include_recipe 'chef-splunk::distsearch_conf' if %w{indexer search}.include?(node[:splunk][:type])
include_recipe 'chef-splunk::inputs_conf' if %w{indexer imforwarder}.include?(node[:splunk][:type])
