# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: distsearch_conf
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
# sets distrubted search settings

search_mnts = []

# loads mount points for search or indexer.
# indexer require may have mulitple mount points if communicating with mutiple search heads and/or search head pools
# search heads only require one mount point for the search pool location.
if node[:splunk][:type] == 'search'
  search_mnts.push(
    mnt: node[:splunk][:searchpool][:pool_mnt],
    device: "#{node[:splunk][:searchpool][:pool_server]}:#{node[:splunk][:searchpool][:pool_mnt]}",
    symlink_loc: node[:splunk][:searchpool][:symlink_location]
  )
  enable = node[:splunk][:searchpool][:enable_pool]
elsif node[:splunk][:type] == 'indexer'
  node[:splunk][:distsearch][:search_bundles].each { |mount|
    search_mnts.push(
      mnt: mount[:bundle_location][:mount_location],
      device: mount[:bundle_location][:nfs_device],
      symlink_loc: mount[:bundle_location][:symlink_location]
    )
  }
  enable = node[:splunk][:distsearch][:mounted_bundles]
  splunk_dirs =  %w{apps users system}
end

# loops through search_mnts which contains directory and nfs device
search_mnts.each { |search_mnt|
  next unless enable
  # creates directory for mount
  directory search_mnt[:mnt] do
    owner     node[:splunk][:dir_perms][:owner]
    group     node[:splunk][:dir_perms][:group]
    mode      node[:splunk][:dir_perms][:mode]
    action    :create
    recursive true
    not_if { ::File.directory?(search_mnt[:mnt]) }
    only_if { enable }
  end

  # mounts nfs device
  mount search_mnt[:device] do
    device      search_mnt[:device]
    mount_point search_mnt[:mnt]
    fstype      'nfs'
    options     'rw,bg,hard,noatime,intr'
    action      [:mount, :enable]
    only_if { enable }
  end

  if node[:splunk][:type] == 'indexer'
    # creates directory for symlinks
    # prevents splunk for access more than nesscary
    directory search_mnt[:symlink_loc] do
      owner     node[:splunk][:dir_perms][:owner]
      group     node[:splunk][:dir_perms][:group]
      mode      node[:splunk][:dir_perms][:mode]
      recursive true
      action    :create
      only_if { enable }
    end

    # creates symlinks
    splunk_dirs.each { |dir|
      symlink = ::File.join(search_mnt[:symlink_loc], dir)
      link_path = ::File.join(search_mnt[:mnt], 'etc', dir)
      link symlink do
        to    link_path
        owner node[:splunk][:dir_perms][:owner]
        group node[:splunk][:dir_perms][:group]
        only_if { enable }
      end
    }
  else
    link search_mnt[:symlink_loc] do
      to    search_mnt[:mnt]
      owner node[:splunk][:dir_perms][:owner]
      group node[:splunk][:dir_perms][:group]
      only_if { enable }
    end
  end
}

# enables search head pooling with  nfs mount point and sets license master
template node[:splunk][:conf_files][:distsearch][:file] do
  source    node[:splunk][:conf_files][:distsearch][:erb]
  owner     node[:splunk][:conf_files][:perms][:owner]
  group     node[:splunk][:conf_files][:perms][:group]
  mode      node[:splunk][:conf_files][:perms][:mode]
  notifies  :restart, 'service[splunk]'
  only_if { %w{indexer search}.include?(node[:splunk][:type]) }
end
