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

Chef::Log.debug('Checking for updates...')
splunk_version_file = ::File.join("#{splunk_dir}", 'etc', 'splunk.version')
Chef::Log.debug("Splunk.version directory: #{splunk_version_file}")
splunk_upgrade = false
splunk_url = node['splunk']['server']['url']
Chef::Log.debug("Splunk url: #{splunk_url}")
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
  splunk_upgrade = (current_splunk_version.strip! != splunk_upgrade_version.strip! && Integer(splunk_upgrade_build) < Integer(current_splunk_build))
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
end

# migration_logs = ::Dir.glob("#{splunk_dir}/var/log/splunk/migration.log.*")
Chef::Log.debug('Accepting license...')
Chef::Log.debug('Complete')
execute 'splunk-unattended-upgrade' do
  command "#{splunk_cmd} start --accept-license --answer-yes"
  only_if { splunk_upgrade }
  not_if { !node[:splunk][:accept_license] }
end
Chef::Log.debug("Checking for upgrade errors..")

# Grabs the migration log to check for upgrade errors. Assumes that the last 
# last element in the list is the most recent upgrade log.
# This doesn't execute correctly (need to delay function or do lazy load/lambda).
ruby_block 'check_upgrade_errors' do
  block do 
    migration_dir = ::File.join("#{splunk_dir}", 'var', 'log', 'splunk', 'migration.log.*')
    migration_logs = ::Dir.glob(migration_dir)
    Chef::Log.debug("Current migration logs: #{migration_logs}")
    most_recent_migration_file = migration_logs.last
    Chef::Log.debug("Most recent migration log: #{most_recent_migration_file}")
    unless ::File.open(most_recent_migration_file, 'r').readlines.grep(/(?i)(copying)/).empty?
      Chef::Log.fatal("There was something wrong with the upgrade of splunk. Check the migration log file in #{most_recent_migration_file}. Stopping splunk...")
      raise
    end
  end
  only_if { splunk_upgrade }
end
