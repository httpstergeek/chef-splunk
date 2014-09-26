# ~FC015
#
# Cookbook Name:: splunk
# Definition:: installer
#
# Author: Joshua Timberman <joshua@getchef.com>
# Copyright (c) 2014, Chef Software, Inc <legal@getchef.com>
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
define :splunk_installer, :url => nil do
  cache_dir = Chef::Config[:file_cache_path]
  package_file = splunk_file(params[:url])
  cached_package = ::File.join(cache_dir, package_file)

  remote_file cached_package do
    source params[:url]
    action :create_if_missing
  end

  if %w{omnios}.include?(node['platform'])
    pkgopts = [
      "-a #{cache_dir}/#{params[:name]}-nocheck",
      "-r #{cache_dir}/splunk-response"
    ]

    execute "uncompress #{cached_package}" do
      not_if { ::File.exists?("#{cache_dir}/#{package_file.gsub(/\.Z/, '')}") }
    end

    cookbook_file "#{cache_dir}/#{params[:name]}-nocheck" do
      source 'splunk-nocheck'
    end

    file "#{cache_dir}/splunk-response" do
      content 'BASEDIR=/opt'
    end
  end

  package params[:name] do
    source cached_package.gsub(/\.Z/, '')
    case node['platform_family']
    when 'rhel'
      provider Chef::Provider::Package::Rpm
    when 'debian'
      provider Chef::Provider::Package::Dpkg
    when 'omnios'
      provider Chef::Provider::Package::Solaris
      options pkgopts.join(' ')
    end
  end
end
