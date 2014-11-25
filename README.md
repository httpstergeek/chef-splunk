Chef-Splunk Cookbook
====================

This cookbook manages a Distributed Splunk Enterprise (server) Enviorment based
on the chef-splunk cookbook by opscode. The intent of this cookbook was build
recipes capable of managing the many role of splunk: search heads, indexer,
heavy forwarders, deployment server, and licensing sever. Each recipe configures
and manages the core features/settings of splunk.

Tasks like licenses are still managed by the administrator. App and TA are still
managed by the Splunk deployment server  

The Splunk default user is admin and the password is changeme. See the
`setup_auth` recipe below for more information about how to manage changing the
password with Chef and Chef Vault. This recipe downloads packages from Splunk
from the Nexus server.There are attributes to set a URL to retrieve the
packages.

Review the attributes section to see which attributes are required for recipe.

**NOTE: Replace All Attributes with values for your ENV**

## Requirements

### Platforms

This cookbook was tested on RHEL6 servers.

### Cookbooks

* `chef-vault` - Used for managing secrets, see chef-splunk.
* `nfs` - Used to configure NFS mount on searchpool.
* `nix_server` - Used to configure Indexers disks.

##Recipes
**NOTE: review nix server attributes section for setting drives
Read Templates section for discription and details regarding attributes
driving template**

###searchpool.rb
searchpool.rb configures server to be  search head pool nfs store. This reciepe
server is the first server to be configure if search head pooling is used.


Recipe includes:

* `chef-splunk::splunk_includes`
* `chef-splunk::nfs_server`

Attributes:

* `node[:splunk][:searchpool][:pool_mnt]`: creates directory where recipe will
  copy apps, users, and system from $SPLUNK_HOME/etc/.
* `node[:splunk][:dir_perms][:owner]`: set owner for apps, users, and system,
  and deploymentclient.conf set by templdate.
* `node[:splunk][:dir_perms][:group]`: set group for apps, users, system, and
  deploymentclient.conf set by templdate.
* `node[:splunk][:dir_perms][:mode]`: set mode for apps, users, and system, and
  deploymentclient.conf set by template.
* `node[:splunk][:deployment_options][:phonehome]`: used by
  system-deploymentclient.conf.erb to set value to phone home to deployment
  server.
* `node[:splunk][:deployment_options][:deployment_uri]`: used by
  system-deploymentclient.conf.erb to set ip, fqdn, or netbios for deployment
  server.
* `node[:splunk][:mgmt_port]`: used by system-deploymentclient.conf.erb to set
  deployment server management port.
* `node[:chef_vault][:version]`: version of chef-vault gem to be installed.
* `node[:chef_vault][:source]`: set ruby gem source.
* `node[:splunk][:user][:username]`: used to create linux user and group for
  splunk. Also sets gid for splunk user.
* `node[:splunk][:user][:comment]`: sets user comments for splunk user.
* `node[:splunk][:user][:shell]`: sets users shell for splunk user.
* `node[:splunk][:user][:uid]`: sets uid for splunk user.
* `node['splunk']['server']['url']`: splunk download location.
* `node[:splunk][:bypass_auth]`: used to bypass setting splunk secrets which
  contains splunk system users configured in `chef-splunk::splunk_secrets`.
* `node[:splunk][:secret]`: databag items for creating splunk.secret.
* `node[:splunk][:passwd]`: databag items for creating passwd.
* `node['splunk']['accept_license']`: accepts license at first startup.
* `node[:splunk][:conf_files][:web][:file]`:  directory to place web.conf from
  template.
* `node[:splunk][:conf_files][:web][:erb]`: erb template to create web.conf.
* `node[:splunk][:conf_files][:perms][:owner]`: sets template owner.
* `node[:splunk][:conf_files][:perms][:group]`: sets template group.
* `node[:splunk][:conf_files][:perms][:mode]`: sets template mode.

Templates:

* `system-deploymentclient.conf.erb`
* `system-web.conf.erb`

```
deploymentclient.conf
[deployment-client]
disabled=<value>

[target-broker:deploymentServer]
targetUri=<value>
```
```
web.conf
startwebserver = 0
```

###search.rb
Configures Splunk search heads with webserver settings.

Recipe includes:

* `chef-splunk::splunk_includes`

Required Attributes:

* `node[:chef_vault][:version]`: version of chef-vault gem to be installed.
* `node[:chef_vault][:source]`: set ruby gem source.
* `node[:splunk][:user][:username]`: used to create linux user and group for
  splunk. Also sets gid for splunk user.
* `node[:splunk][:user][:comment]`: sets user comments for splunk user.
* `node[:splunk][:user][:shell]`: sets users shell for splunk user.
* `node[:splunk][:user][:uid]`: sets uid for splunk user.
* `node['splunk']['server']['url']`: splunk download location.
* `node[:splunk][:bypass_auth]`: used to bypass setting splunk secrets which
  contains splunk system users configured in `chef-splunk::splunk_secrets`.
* `node[:splunk][:secret]`: databag items for creating splunk.secret.
* `node[:splunk][:passwd]`: databag items for creating passwd.
* `node['splunk']['accept_license']`: accepts license at first startup.
* `node[:splunk][:ssl_options][:enable_ssl]`: enables settings loading web ssl
  data bag, creation of certs with file mask settings.
* `node[:splunk][:conf_files][:web][:file]`: absolute path to place web.conf
  from template.
* `node[:splunk][:conf_files][:web][:erb]`: erb template to create web.conf.
* `node[:splunk][:conf_files][:distsearch][:file]`: absolute path to place
  distsearch.conf.
* `node[:splunk][:conf_files][:distsearch][:erb]`: erb template to create
  distsearch.conf.
* `node[:splunk][:conf_files][:perms][:owner]`: sets all template owner.
* `node[:splunk][:conf_files][:perms][:group]`: sets all template group.
* `node[:splunk][:conf_files][:perms][:mode]`: sets all template mode.
* `node[:splunk][:searchpool][:pool_mnt]`: directory to mount search pool nfs
  storage.
* `node[:splunk][:searchpool][:pool_server]`: nfs search pool storage ip.
  Combined with `node[:splunk][:searchpool][:pool_mnt]` to build device to
  mount.
* `node[:splunk][:searchpool][:symlink_location]`: location to create symlinks
  for search pool mount.
* `node[:splunk][:searchpool][:enable_pool]`: if set to "enabled" seach head
  pooling is enabled for search head.
* `node[:splunk][:dir_perms][:owner]`: sets symlink and directory owner.
* `node[:splunk][:dir_perms][:group]`: sets symlink and directory group.
* `node[:splunk][:dir_perms][:mode]`: sets symlink and directory mode.

Templates:

* `system-deploymentclient.conf.erb`
* `system-web.conf.erb`
* `system-distritsearch.conf.erb`
* `system-server.conf.erb`

```
server.conf
[pooling]
state=<value>
storage=<value>
```
```
deploymentclient.conf
[deployment-client]
disabled=<value>

[target-broker:deploymentServer]
targetUri=<value>
```
```
web.conf
startwebserver=0
enableSplunkWebSSL=<value>
privKeyPath=etc/auth/splunkweb/<value>
caCertPath=etc/auth/splunkweb<value>
```
```
distsearch.conf
[distributedSearch]
shareBundles=<value>
servers=<values>
```

###indexer.rb
indexer.rb configures Splunk indexers to recives  disables webserver
functions.

Recipe includes:

* `chef-splunk::splunk_includes`

Required Attributes:

* `node[:splunk][:set_db]`: creates directory where recipe will move default
  index location. $SPLUNK\_DB
* `node[:splunk][:dir_perms][:owner]`: set owner all directories and files
* `node[:splunk][:dir_perms][:group]`: set group all directories and files
* `node[:splunk][:dir_perms][:mode]`: set mode for all directories and files
* `node[:chef_vault][:version]`: version of chef-vault gem to be installed.
* `node[:chef_vault][:source]`: set ruby gem source.
* `node[:splunk][:user][:username]`: used to create linux user and group for
  splunk. Also sets gid for splunk user.
* `node[:splunk][:user][:comment]`: sets user comments for splunk user.
* `node[:splunk][:user][:shell]`: sets users shell for splunk user.
* `node[:splunk][:user][:uid]`: sets uid for splunk user.
* `node['splunk']['server']['url']`: splunk download location.
* `node[:splunk][:bypass_auth]`: used to bypass setting splunk secrets which
  contains splunk system users configured in `chef-splunk::splunk_secrets`.
* `node[:splunk][:secret]`: databag items for creating splunk.secret.
* `node[:splunk][:passwd]`: databag items for creating passwd.
* `node['splunk']['accept_license']`: accepts license at first startup.
* `node[:splunk][:receiver_options][:splunktcp_ssl]`: enables splunk receiver
  ssl, and loads data bag to create root ca and server cert files.
* `node[:splunk][:conf_files][:inputs][:file]`: absolute path to place
  inputs.conf.
* `node[:splunk][:conf_files][:inputs][:erb]`: erb teamplate to create
  inputs.conf.
* `node[:splunk][:conf_files][:web][:file]`: absolute path to place web.conf  
  from template.
* `node[:splunk][:conf_files][:web][:erb]`: erb template to create web.conf.  
* `node[:splunk][:conf_files][:distsearch][:file]`: absolute path to place
  distsearch.conf.
* `node[:splunk][:conf_files][:distsearch][:erb]`: erb template to create
  distsearch.conf.
* `node[:splunk][:conf_files][:perms][:owner]`: sets all template owner.
* `node[:splunk][:conf_files][:perms][:group]`: sets all template group.
* `node[:splunk][:conf_files][:perms][:mode]`: sets all template mode.
* `node[:splunk][:distsearch][:mounted_bundles]`: enables search bundles
* `node[:splunk][:distsearch][:search_bundles]`: search bundle locations for
  search heads.
* `node[:splunk][:dir_perms][:owner]`: sets symlink and directory owner.
* `node[:splunk][:dir_perms][:group]`: sets symlink and directory group.
* `node[:splunk][:dir_perms][:mode]`: sets symlink and directory mode.

Templates:

* `system-deploymentclient.conf.erb`
* `system-web.conf.erb`
* `system-distritsearch.conf.erb`
* `system-splunk-launch.conf.erb`
* `system-inputs.conf.erb`
* `system-server.conf.erb`

```
server.conf
[license]  
master_uri=<value>
```
```
deploymentclient.conf
[deployment-client]
disabled=<value>

[target-broker:deploymentServer]
targetUri=<value>
```
```
web.conf
startwebserver=0
```
```
distsearch.conf
[searchhead:<value]
mounted_bundles=<value>
bundles_location=<values>
```
```
splunk-launch.conf
SPLUNK_HOME=/opt/splunk
SPLUNK_SERVER_NAME=splunkd
SPLUNK_WEB_NAME=splunkweb
SPLUNK_DB=<value>
```
```
inputs.conf
[default]
host=<value>

[SSL]
rootCA=<value>
serverCert=<value>

[splunktcp:<value>]

[udp:<value>]

[tcp:<value>]
```

###deployserver.rb
Configures Deployment server with web server and install git.

Recipe includes:

* `chef-splunk::splunk_includes`
* `rhn_satellite`

Attributes:

* `node[:splunk][:dir_perms][:owner]`: set owner all directories and files
* `node[:splunk][:dir_perms][:group]`: set group all directories and files
* `node[:splunk][:dir_perms][:mode]`: set mode for all directories and files
* `node[:splunk][:deployment_options][:phonehome]`: used by
  system-deploymentclient.conf.erb to set value to phone home to deployment
  server.
* `node[:splunk][:deployment_options][:deployment_uri]`: used by
  system-deploymentclient.conf.erb to set ip, fqdn, or netbios for deployment
  server.
* `node[:splunk][:mgmt_port]`: used by system-deploymentclient.conf.erb to set  
  deployment server management port.
* `node[:chef_vault][:version]`: version of chef-vault gem to be installed.
* `node[:chef_vault][:source]`: set ruby gem source.
* `node[:splunk][:user][:username]`: used to create linux user and group for
  splunk. Also sets gid for splunk user.
* `node[:splunk][:user][:comment]`: sets user comments for splunk user.
* `node[:splunk][:user][:shell]`: sets users shell for splunk user.
* `node[:splunk][:user][:uid]`: sets uid for splunk user.
* `node['splunk']['server']['url']`: splunk download location.
* `node[:splunk][:bypass_auth]`: used to bypass setting splunk secrets which
  contains splunk system users configured in `chef-splunk::splunk_secrets`.
* `node[:splunk][:secret]`: databag items for creating splunk.secret.
* `node[:splunk][:passwd]`: databag items for creating passwd.
* `node['splunk']['accept_license']`: accepts license at first startup.
* `node[:splunk][:conf_files][:serverclass][:file]`: absolute path to place
  serverclass.conf.
* `node[:splunk][:conf_files][:serverclass][:erb]`: erb template to create
  serverclass.conf.
* `node[:splunk][:conf_files][:web][:file]`: absolute path to place web.conf
  from template.
* `node[:splunk][:conf_files][:web][:erb]`: erb template to create web.conf.
* `node[:splunk][:conf_files][:perms][:owner]`: sets all template owner.
* `node[:splunk][:conf_files][:perms][:group]`: sets all template group.
* `node[:splunk][:conf_files][:perms][:mode]`: sets all template mode.
* `node[:splunk][:iptables][:redirect]`: enables iptables for port redirection.
* `node[:splunk][:iptables][:iptable_src]`: absolute path to place iptables.
* `node[:splunk][:iptables][:iptable_tgt]`: erb template to create iptables.

Templates:

* `system-serverclass.conf.erb`
* `system-server.conf.erb`
* `deploy_redirect.erb`

```
web.conf
startwebserver=0
```
```
server.conf
[license]  
master_uri=<value>
```

###imforwarder.rb
Configures Splunk intermediate forwarder.

Recipe includes:

* `chef-splunk::splunk_includes`

Attributes:

* `node[:splunk][:dir_perms][:owner]`: set owner all directories and files
* `node[:splunk][:dir_perms][:group]`: set group all directories and files
* `node[:splunk][:dir_perms][:mode]`: set mode for all directories and files
* `node[:chef_vault][:version]`: version of chef-vault gem to be installed.
* `node[:chef_vault][:source]`: set ruby gem source.
* `node[:splunk][:user][:username]`: used to create linux user and group for
  splunk. Also sets gid for splunk user.
* `node[:splunk][:user][:comment]`: sets user comments for splunk user.
* `node[:splunk][:user][:shell]`: sets users shell for splunk user.
* `node[:splunk][:user][:uid]`: sets uid for splunk user.
* `node['splunk']['server']['url']`: splunk download location.
* `node[:splunk][:bypass_auth]`: used to bypass setting splunk secrets which
  contains splunk system users configured in `chef-splunk::splunk_secrets`.
* `node[:splunk][:secret]`: databag items for creating splunk.secret.
* `node[:splunk][:passwd]`: databag items for creating passwd.
* `node['splunk']['accept_license']`: accepts license at first startup.
* `node[:splunk][:receiver_options][:splunktcp_ssl]`: enables splunk receiver
  ssl, and loads data bag to create root ca and server cert files.
* `node[:splunk][:conf_files][:inputs][:file]`: absolute path to place
  inputs.conf.
* `node[:splunk][:conf_files][:inputs][:erb]`: erb teamplate to create
  inputs.conf.
* `node[:splunk][:conf_files][:web][:file]`: absolute path to place web.conf
  from template.
* `node[:splunk][:conf_files][:web][:erb]`: erb template to create web.conf.    .
* `node[:splunk][:conf_files][:outputs][:file]`: absolute path to place
  outputs.conf.
* `node[:splunk][:conf_files][:outputs][:erb]`: erb template to create
  outputs.conf.
* `node[:splunk][:conf_files][:perms][:owner]`: sets all template owner.
* `node[:splunk][:conf_files][:perms][:group]`: sets all template group.
* `node[:splunk][:conf_files][:perms][:mode]`: sets all template mode.

Templates:

* `system-deploymentclient.conf.erb`
* `system-web.conf.erb`
* `system-inputs.conf.erb`
* `system-outputs.conf.erb`
* `system-server.conf.erb`

```
deploymentclient.conf
[deployment-client]
disabled=<value>

[target-broker:deploymentServer]
targetUri=<value>
```
```
web.conf
startwebserver=0
```
```
inputs.conf
[default]
host=<value>

[SSL]
rootCA=<value>
serverCert=<value>

[splunktcp:<value>]

[udp:<value>]

[tcp:<value>]
```
```
outputs.conf
[tcpout]
indexAndForward=true
```

###inputs.conf.rb
Sets values for recieving ports such as splunktcpssl, splunktcp, tcp, udp used
in `system-inputs.conf.erb` template.

Attributes:

* `node['splunk']['reciever_options']['splunktcp_ssl']['enable_splunktcp_ssl']`
* `node['splunk']['reciever_options']['splunktcp_ssl']`
* `node[:splunk][:conf_files][:perms][:owner]`
* `node[:splunk][:conf_files][:perms][:group]`
* `node[:splunk][:conf_files][:perms][:mode]`
* `node[:splunk][:conf_files][:inputs][:file]`
* `node[:splunk][:conf_files][:inputs][:erb]`

Templates:
* `system-inputs.conf.erb`

###distsearch_conf.rb

sets values for distsearch.conf such as shared bundles, search pool members,
mounted bundles and mounted bundle location.

Attributes:

* `node[:splunk][:searchpool][:pool_mnt]`
* `node[:splunk][:searchpool][:pool_server]`
* `node[:splunk][:searchpool][:symlink_location]`
* `node[:splunk][:searchpool][:enable_pool]`
* `node[:splunk][:distsearch][:search_bundles]`
* `node[:splunk][:dir_perms][:owner]`
* `node[:splunk][:dir_perms][:group]`
* `node[:splunk][:conf_files][:distsearch][:erb]`
* `node[:splunk][:conf_files][:distsearch][:file]`
* `node[:splunk][:conf_files][:perms][:owner]`
* `node[:splunk][:conf_files][:perms][:group]`
* `node[:splunk][:conf_files][:perms][:mode]`

Templates:

* `system-distsearch.conf.erb`

###nfs_server.rb
Configures NFS server export for nfs server.

Attributes:

* `node['splunk']['searchpool']['pool_mnt']`
* `node['splunk']['searchpool']['network']`
* `node[:splunk][:dir_perms][:owner]`
* `node[:splunk][:dir_perms][:group]`
* `node[:splunk][:dir_perms][:mode]`

###server_conf.rb
Configures server.conf by create a template to set search head pooling and
licensing master.

Attributes:

* `node[:splunk][:conf_files][:server][:file]`
* `node[:splunk][:conf_files][:server][:erb]`
* `node[:splunk][:conf_files][:perms][:owner]`
* `node[:splunk][:conf_files][:perms][:group]`
* `node[:splunk][:conf_files][:perms][:mode]`

###splunk_secrets.rb
Uses data bags create passwd and splunk.secret file. passwd has all users and
password pre-created.

Attributes:

* `node[:splunk][:secret]`
* `node[:splunk][:passwd]`

##splunk_includes.rb
Disables iptables if running in solo mode and install chef-vault gem. Recipe has
has all include_recipes common for all splunk roles.

Attributes:

* `version node[:chef_vault][:version]`
* `options node[:chef_vault][:source]`  

###web_conf.rb
Creates cets and keys from data bags. Deploys web.conf from tempate

Attributes:

* `node['splunk']['ssl_options']['enable_ssl']`
* `node['splunk']['ssl_options']`
* `node[:splunk][:conf_files][:web][:file]`
* `node[:splunk][:conf_files][:web][:erb]`
* `node[:splunk][:conf_files][:perms][:owner]`
* `node[:splunk][:conf_files][:perms][:group]`
* `node[:splunk][:conf_files][:perms][:mode]`

Templates:

* `system-web.conf.erb`

##Templates

###system-deploymentclient.conf.rb
Configures deploymentserver location, phoneHome intervals

Attributes:

* `node['splunk']['deployment_options']['phonehome']`: Sets phoneHome intervals
  in seconds
* `node['splunk']['deployment_options']['deployment_uri']`: Sets deployment
  server and port.  `"<SERVER>:8089"`

###system-distsearch.conf.erb
Configures distsearch mounted bundles and search peers for search or indexers.

Attributes:

* `node[:splunk][:distsearch][:share_bundles]`: enables/ disables shareBundles
* `node[:splunk][:distsearch][:search_peers]`: outputs list of
  search peers.
* `node[:splunk][:distsearch][:search_bundles]`: search heads and bundles
  locations.

###system-inputs.conf.erb
Configures inputs.conf for Indexers or Intermediate forwarders

Attributes:

* `node['hostname']`: Sets Splunk Host Name. *DO NOT MODIFY*
* `node['splunk']['reciever_options']['splunktcp_ssl']['enable_splunktcp_ssl']`
  Enables SSL to be configured on indexer
* `node['splunk']['reciever_options']['splunktcp_ssl']['root_ca']`: Value for
  servers need to successful recieve SSL data for Forwarder.  Forwarder MUST have
  the same root cert.
* `node['splunk']['reciever_options']['splunktcp_ssl']['server_cert']`: Value
  for servers need to successful recieve SSL data for Forwarder.  Forwarder MUST
  have the same ca cert.
* `node['splunk']['reciever_options']['splunktcp_ssl']['port']`:  splunkssltcp listening
  port.
* `node['splunk']['reciever_options']['splunktcp']['enable_splunktcp']`: Enables
  standard splunktcp port on indexer
* `node['splunk']['reciever_options']['splunktcp']['port']`: splunktcp listening
  port
* `node['splunk']['reciever_options']['udp']['enable_udp']`: enables udp
  listening on indexer
* `node['splunk']['reciever_options']['udp']['ports']`: List of ports to
  enable for udp listening.  Values *must* be Strings.
* `node['splunk']['reciever_options']['tcp']['enable_tcp']`: enables generic tcp
  listening on indexer
* `node['splunk']['reciever_options']['tcp']['ports']`: List of ports to enable
  to for tcp listening.  Values *must* be strings

###system-outputs.conf.erb
Sets indexAndForward value for intermediate forwarders.

Attributes:
None

###system-server.conf.erb
Read default file server.conf.orig to create template.

Attributes:

* `node[:splunk][:searchpool][:enable_pool]`: enables/ disables search head
  pooling.
* `node[:splunk][:searchpool][:symlink_location]`: location to search pool
  mounted device.
* `node[:splunk][:license_uri]`: license master address or fqdn
* `node[:splunk][:mgmt_port]`: splunk management port.

###system-severclass.conf.erb
Sets global serverclass.conf settings.

###system-splunk-launch.conf.erb
Sets $SPLUNK_DB location.

* `node[:splunk][:set_db]`:  Absolute path to splunk DB location.

###system-web.conf.erb
Enables or disables webserver and sets SSL for webserver.

Attributes:

* `node[:splunk][:webserver_options][:port]`: sets web server port.
* `node[:splunk][:webserver_options][:update_checker_url]`: sets update url to
  off.
* `node[:splunk][:ssl_options][:enable_ssl]`: enables SplunkWebSSL.
* `node[:splunk][:ssl_options][:keyfile]`: privKeyPath for splunk cert.
* `node[:splunk][:ssl_options][:crtfile]`: Splunk cert.

##Usage
**NOTE: Follow Splunk Documentation for creatin Certs**
###Splunk Secrets
You can uses `node[:splunk][:secrets]` to store the passwd and splunk.secret.
Both file are typically generated at splunk start.  The splunk.secret file helps
set the encryption key used for things like SSL key files, LDAP service
accounts, and so on. For systems that will need to share identical copies of
files containing splunk encrypted password data.  To generate files simple start
a fresh install of splunk then change the admin password.

```
$SPLUNK_HOME/bin/splunk edit user admin -password -roles admin
or
$SPUNK_HOME/splunk add user noobie -password "changeme" \
-full-name 'New User' -role User
```
The $SPLUNK_HOME/etc/passwd and $SPLUNK_HOME/etc/auth/splunk.secret can be
copied into your data bag.

```
knife vault create vault splunk_passwd_ENV --file $SPLUNK_HOME/etc/passwd -A user
knife vault create vault splunk_secret_ENV --file $SPLUNK_HOME/etc/auth/splunk.secret -A user
```

###WEB UI
A Splunk server should have the Web UI available via HTTPS. This can be set up
using self-signed SSL certificates, or "real" SSL certificates. This loaded via
a data bag item with knife vault.

```
knife vault create vault splunk_webcert_ENV --file <yourWebCert>.pem -A user
knife vault create vault splunk_webkey_ENV --file <yourWebCertkey>.key -A user
```

###Splunk SSL receiver

A Splunk indexer and forwarder can use SSL by configuring this bag. If you you
are using the splunk secret to on all splunk instances you can use the default
cert.

```
knife vault create vault splunk_recrootca_ENV --file <yourRootCA>.pem -A user
knife vault create vault splunk_recservercert_ENV --file <yourServerCert>.pem -A user
```

###Building Servers
This cook can build a Distributed ENV soup to nuts with search pooling and
mounted bundles.

1. Setup one Search Pool NFS storage using the searchpool recipe.
   Alternatively you can setup copy the necessary directories and files to your
   NAS device.
2. Configure your Search Heads using the search recipe. If you are using search
   head pool set `node[:splunk][:searchpool]` to enabled  and list all search
   heads uses your search pool in `node[:splunk][:distsearch][search_heads]` and
   set `node[:splunk][:distsearch][share_bundles]` to false. Even though search
   peers are preconfigure Administrators will still need to the user name and
   password.
3. Configure your Indexer use the indexer recipe.  If you which enable mounted
   bundles set `node[:splunk][:distsearch][mounted_bundles]` to true and specify
   `nfs_device` and `mount_location` in `node[:splunk][:distsearch]`.
4. Configure an Intermediate forwarder use imforwarder recipe.
5. Configure an deployment server use deployserver recipe.  Minimal settings are
   confifured and is optional

It you to the Splunk admin to determine where to install the licensing server.
The Splunk Admin **MUST NOT MODIFY** items in $SPLUNK_HOME/etc/system/local
directory as those are system managed.


## License and Authors

- Authors: Bernardo Macias <bmacias84s@gmail.com> & Jim Parry

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
