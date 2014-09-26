# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: nfs_server
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

include_recipe 'nfs::server'

nfs_mnt = node[:splunk][:searchpool][:pool_mnt]
Chef::Log.debug(nfs_mnt)
directory 'nfs_mnt' do
  owner  node[:splunk][:dir_perms][:owner]
  group  node[:splunk][:dir_perms][:group]
  mode   node[:splunk][:dir_perms][:mode]
  action :create
end

export_name = %r{\/[^\/]+$}.match(nfs_mnt).to_s

nfs_export export_name do
  directory nfs_mnt
  network   node[:splunk][:searchpool][:network]
  writeable true
  sync      true
  options   %w{no_root_squash no_subtree_check nohide no_wdelay}
end
