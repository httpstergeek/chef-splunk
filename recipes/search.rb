# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: search
# Author: Bernardo Macias <bmacias84@gmail.com>
#
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

# Sets server type for configuring search server.
node.default[:splunk][:type] = 'search'
include_recipe 'chef-splunk::splunk_includes'

# Creates .ui_login to bypass change password prompt
login_ui = ::File.join(splunk_dir, 'etc', '.ui_login')
cookbook_file login_ui do
  source '.ui_login'
end

# Tempalte to set ui-prefs
template node[:splunk][:conf_files][:ui_prefs][:file] do
  source   node[:splunk][:conf_files][:ui_prefs][:erb]
  owner    node[:splunk][:conf_files][:perms][:owner]
  group    node[:splunk][:conf_files][:perms][:group]
  mode     node[:splunk][:conf_files][:perms][:mode]
  notifies :restart, 'service[splunk]'
end
