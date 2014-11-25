# encoding: utf-8
#
# Cookbook Name:: chef-splunk
# Recipe:: default
#
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
#

if node[:splunk][:disabled]
  include_recipe 'chef-splunk::disabled'
  Chef::Log.debug('Splunk is disabled on this node.')
  return
end

if node[:splunk][:is_server]
  include_recipe "chef-splunk::#{node[:splunk][:type]}"
else
  include_recipe 'chef-splunk::client'
end
