# CHANGELOG chef-splunk

# 0.5.20
 * Added "status: true" for iptables service check

# 0.5.19
 * Add iptables for port redirects on deployment servers

# 0.5.18
 * Remove pinning for nix cookbook

# 0.5.17
 * Fix for chef 11.12.2 for handling loops where source not set.  Re-raising
   exception: ArgumentError - You must supply a name when declaring a directory
resource

# 0.5.16
 * Fixed searchpool enable/disable bug

# 0.5.15
 * Added Tuned cookbook

# 0.5.14
 * Added Java cookbook

# 0.5.13
 * Fixed NFS permissions.

# 0.5.12
 * value for pooling was true but template should have value enabled

# 0.5.8
 * corrected bug created by pervious change

# 0.5.7
  * removed etc/etc path from distsearch_conf.rb

# 0.5.6
 * Added creation of indexes.conf in $SPLUNK_HOME/etc/system/local/
 * Change system-server.conf.erb to use https for license master.

# 0.5.5
 * updated system-server_conf.rb to for searchpool enabled to bool.

# 0.5.3
 * updated nfs and mount options
