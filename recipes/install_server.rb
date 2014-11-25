#
# Cookbook Name:: chef-splunk
# Recipe:: install_server
#
# Author: Jessica Wong <jessica.wong@nordstrom.com>
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

splunk_version_file = ::File.join(splunk_dir, 'etc', 'splunk.version')
Chef::Log.debug("Splunk.version directory: #{splunk_version_file}")
splunk_upgrade = false
splunk_url = node['splunk']['server']['url']
is_installed = ::File.exist?(splunk_version_file)

Chef::Log.debug("Splunk installed? #{is_installed}")

if is_installed
  splunk_upgrade_flags = /\S+\.rpm/.match(splunk_url.split('/').last).to_s.split('-')
  Chef::Log.debug("Splunk download file: #{splunk_upgrade_flags}")
  splunk_upgrade_version = splunk_upgrade_flags[1]
  Chef::Log.debug("Splunk Upgrade Version: #{splunk_upgrade_version}")
  splunk_upgrade_build = splunk_upgrade_flags[2]
  Chef::Log.debug("Splunk Upgrade Build: #{splunk_upgrade_build}")
  splunk_current_file = ::File.open(splunk_version_file, 'r')
  current_splunk = splunk_current_file.readlines
  current_splunk_version = current_splunk[0].split('=')[1]
  splunk_current_file.close
  Chef::Log.debug("Installed Splunk Version: #{current_splunk_version}")
  current_splunk_build = current_splunk[1].split('=')[1]
  Chef::Log.debug("Installed Splunk Build: #{current_splunk_build}")
  splunk_upgrade = (current_splunk_version.strip! != splunk_upgrade_version.strip! && Integer(splunk_upgrade_build) > Integer(current_splunk_build))
end

Chef::Log.debug("Upgrade Splunk? #{splunk_upgrade}")
node.default[:splunk_upgrade] = splunk_upgrade

service 'splunk_stop' do
  service_name 'splunk'
  Chef::Log.debug('Upgrading Splunk...')
  supports status: true
  provider Chef::Provider::Service::Init
  Chef::Log.debug('Stopping Splunk...')
  action :stop
  only_if { splunk_upgrade }
end

Chef::Log.debug('Installing...')
splunk_installer 'splunk' do
  url splunk_url
  notifies :run, 'execute[splunk-unattended-upgrade]', :immediately
end

# migration_logs = ::Dir.glob("#{splunk_dir}/var/log/splunk/migration.log.*")
execute 'splunk-unattended-upgrade' do
  Chef::Log.debug('Accepting license...')
  command "#{splunk_cmd} start --accept-license --answer-yes"
  only_if { splunk_upgrade }
end
