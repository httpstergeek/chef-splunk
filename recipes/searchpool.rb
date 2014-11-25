# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: searchpool
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
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default[:splunk][:type] = 'searchpool'
# this overrids default attributes for servers running this recipe
# node.default['splunk']['webserver_options']['enable_webserver'] = false

include_recipe 'chef-splunk::splunk_includes'
include_recipe 'chef-splunk::nfs_server'

# directories to create and copy from
splunk_dirs =  %w{apps users system}

nfs_dir = node[:splunk][:searchpool][:pool_mnt]
# copies directories nesscary for directories to nfs mount nesscary
# for splunk search head pooling
splunk_dirs.each do |dir|
  dir = ::File.join('etc', dir)
  splunk_mnt_dir = ::File.join(nfs_dir, dir)

  # stops splunk service if splunk_mnt_dir not found
  service 'splunk' do
    supports status: true
    action   :stop
    not_if { File.directory?(splunk_mnt_dir) }
  end

  # creates splunk_mnt_dir and parent directories
  directory splunk_mnt_dir do
    owner     node[:splunk][:dir_perms][:owner]
    group     node[:splunk][:dir_perms][:group]
    mode      node[:splunk][:dir_perms][:mode]
    action    :create
    recursive true
  end

  # subscribes to directory[#{splunk_mnt_dir}] resource
  # copy default splunk_db to splunk_mnt_dir and perserves rights.
  execute 'copy_splunk_dirs' do
    command    "cp -rp #{splunk_dir}/#{dir}/* #{splunk_mnt_dir}"
    action     :nothing
    subscribes :run, "directory[#{splunk_mnt_dir}]", :immediately
    notifies   :restart, 'service[splunk]'
  end
end

if node[:splunk_upgrade]
  app_dirs =  %w{framework gettingstarted legacy search launcher SplunkForwarder SplunkLightForwarder}
  app_dirs.each do |dir|
    src_directory = ::File.join(splunk_dir, 'etc', 'apps', dir)
    dest_directory = ::File.join(nfs_dir, 'etc', 'apps')
    Chef::Log.debug("source dir: #{src_directory}")
    Chef::Log.debug("destination dir: #{dest_directory}")
    execute 'copy_splunk_apps' do
      command   "cp -rfp #{src_directory} #{dest_directory}"
    end
  end
end

# Template sets deployment client configuration
template node[:splunk][:conf_files][:deployclient][:file]  do
  source   node[:splunk][:conf_files][:deployclient][:erb]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  mode     node[:splunk][:conf_files][:perms][:mode]
  notifies :restart, 'service[splunk]'
end
