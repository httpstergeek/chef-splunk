# encoding: utf-8
# Cookbook Name:: chef-splunk
# Attributes:: java.rb
#
#
# All rights reserved - Do Not Redistribute
#

default[:java][:arch]           = 'x86_64'
default[:java][:install_flavor] = 'oracle'
default[:java][:jdk_version]    = '7'
default[:java][:arch]           = 'x86_64'
default['java']['jdk']['7']['x86_64']['url'] = 'https://repo.compnay.net//repositories/thirdparty/com/oracle/java/jdk/7u51/jdk-7u51-linux-x64.tar.gz'
