# encoding: utf-8
# Cookbook Name:: chef-splunk
# Recipe:: splunk_secrets
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

# load data bag for splunk
splunk_secrets =[node[:splunk][:secret], node[:splunk][:passwd]]

splunk_secrets.each { |secret|
  secret = ChefVault::Item.load(
    secret[:data_bag],
    secret[:data_bag_item]
  )
  splunk_file = ::File.join(splunk_dir, 'etc')
  splunk_file = ::File.join(splunk_file, 'auth') if secret['file-name'] == node[:splunk][:secret][:file]
  splunk_file = ::File.join(splunk_file, secret['file-name'])
  # creates files from databag
  file splunk_file do
    content secret['file-content']
    mode   0400
    action :create_if_missing
  end
}
