This is an example file for the nix_server attributes works for Vagrant ENV.

```ruby
# encoding: utf-8
# Cookbook Name:: chef-splunk
# Attributes:: nix_server
#
#
# All rights reserved - Do Not Redistribute
#

#
## All Splunk servers have the following common nix_server components:
#

# LVM volume groups
default[:nix_server][:volume_groups] = {
  VGSplunk00: {
    physvols: ['/dev/sdb', '/dev/sdc']
  }
}

# LVM volumes to create
default[:nix_server][:lvmvols] = {
  optsplunk: {
    group:  'VGSplunk00',
    size:   '66%VG',
    filesystem: 'ext4',
    mount_point: {
      location: '/opt/splunk',
      dump:      0,
      pass:      2
    }
  },
  tmpsplunk: {
    group:  'VGSplunk00',
    size:   '34%VG',
    filesystem: 'ext4',
    mount_point: {
      location: '/tmp/splunk',
      dump:      0,
      pass:      2
    }
  }
}

#
# Below are nix_server compnents unique to Splunk Indexer servers
#
if node[:splunk][:type] == 'indexer'
  default[:nix_server][:first_directories].merge!(
    optsplunkmnt: {
      name:  '/opt/splunk/mnt',
      owner: 'root',
      group: 'root',
      mode:  '0755',
      recursive: true
    }
  )
  # LVM volume groups
  default[:nix_server][:volume_groups].merge!(
    VGSplunk01: {
      physvols: ['/dev/sdd', '/dev/sde']
    },
    VGSplunk02: {
      physvols: ['/dev/sdf', '/dev/sdg']
    },
    VGSplunk03: {
      physvols: ['dev/sdh']
    }
  )

  # LVM logical volumes
  default[:nix_server][:lvmvols].merge!(
    Index01: {
      group: 'VGSplunk01',
      size:  '100%VG',
      filesystem: 'ext4',
      mount_point: {
        location: '/opt/splunk/mnt/index01',
        dump: 0,
        pass: 2
      }
    },
    Index02: {
      group: 'VGSplunk02',
      size:  '100%VG',
      filesystem: 'ext4',
      mount_point: {
        location: '/opt/splunk/mnt/index02',
        dump: 0,
        pass: 2
      }
    },
    Index03: {
      group: 'VGSplunk03',
      size:  '100%VG',
      filesystem: 'ext4',
      mount_point: {
        location: '/opt/splunk/mnt/index03',
        dump: 0,
        pass: 2
      }
    }
  )
end

if node[:splunk][:type] == 'searchpool'
  default[:nix_server][:volume_groups].merge!(
    VGSplunk04: {
      physvols: ['/dev/sdd']
    }
  )

  default[:nix_server][:lvmvols].merge!(
    Index01: {
      group: 'VGSplunk04',
      size:  '100%VG',
      filesystem: 'ext4',
      mount_point: {
        location: node[:splunk][:searchpool][:pool_mnt],
        dump: 0,
        pass: 2
      }
    }
  )
end
```
