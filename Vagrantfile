# -*- mode: ruby -*-
# vi: set ft=ruby :

# Tested with vagrant 1.4.1 on Mac OS 10.8.4

Vagrant.configure("2") do |config|
  hostetc                         = false
  user                            = "#{ENV['user']}"
  config.ssh.username             = "vagrant"
  base_box_url                    = ""
  boxname                         = ""
  chef_base_path                  = "#{ENV['cookbooks']}/cookbooks"
  databag_path                    = "#{ENV['cookbooks']}/data_bags"
  data_bag_secret_key_path        = "#{ENV['cookbooks']}/data_bags/vault"
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled        = true
# config.omnibus.chef_version    = :latest
# config.omnibus.chef_version     = '11.4.0'
  # sets vagrant proxy
  if Vagrant.has_plugin?("vagrant-proxyconf")
   # config.env_proxy.http  = "yourproxy:8080"
   # config.env_proxy.https = "yourproxy:8080"
    config.proxy.http       = "#{ENV['http_proxy']}"
    config.proxy.https      = "#{ENV['https_proxy']}"
    config.proxy.no_proxy   = "*.local, 169.254/16"
  end

  # cache common items between vms
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
  #  config.cache.synced_folder_opts = {
  #    type: :nfs,
  #    mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
  #  }
  end

  # Splunk Indexer vbox
  config.vm.define :indexer do |box|
    type                = 'indexer'
    box.vm.hostname     = "#{ENV['USER']}-#{type}"
    box.vm.box          = boxname
    box.vm.synced_folder "#{ENV['USER']}/.chef", '/etc/chef'   
    box.vm.synced_folder databag_path, "/var/chef/data_bags"
    box.vm.network :private_network, ip: '33.33.33.11', virtualbox__intnet: "mynetwork"
    box.vm.provider :virtualbox do |vb|
      vb.gui = true
      # memory
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
      # create drives
      vb.customize ["createhd", "--filename", "sdb-#{type}", "--size", 20480, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdc-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdd-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sde-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdf-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdg-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdh-#{type}", "--size", 10240, "--format", "VMDK"]
      # create controller
      vb.customize ["storagectl", :id, "--name", "SCSI Controller", "--add", "scsi", "--controller", "LsiLogic", "--bootable", "off"]
      # attach drives to controller
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 0, "--medium", "sdb-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 1, "--medium", "sdc-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 2, "--medium", "sdd-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 3, "--medium", "sde-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 4, "--medium", "sdf-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 5, "--medium", "sdg-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 6, "--medium", "sdh-#{type}.vmdk", "--type", "hdd"]
    end
    box.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.node_name = user
      chef.json = {
        'splunk' => {
          'type' => "#{type}"
        }
      }
      chef.run_list = [
        "recipe[chef-splunk]"
      ]
    end
  end # Splunk Indexer vbox

  ## Splunk Search Head vbox
  config.vm.define :search do |box|
    type            = 'search'
    box.vm.hostname = "#{ENV['USER']}-#{type}"
    box.vm.box      = boxname
    box.vm.synced_folder "#{ENV['USER']}/.chef", '/etc/chef'   
    box.vm.synced_folder databag_path, "/var/chef/data_bags"
    box.vm.network :private_network, ip: '33.33.33.12', virtualbox__intnet: "mynetwork"
    box.vm.network :forwarded_port, host: 4431, guest: 443
    box.vm.provider :virtualbox do |vb|
      vb.gui = true
      # memory
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
      # create drives
      vb.customize ["createhd", "--filename", "sdb-#{type}", "--size", 20480, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdc-#{type}", "--size", 10240, "--format", "VMDK"]
      # create controller
      vb.customize ["storagectl", :id, "--name", "SCSI Controller", "--add", "scsi", "--controller", "LsiLogic", "--bootable", "off"]
      # attach drives to controller
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 0, "--medium", "sdb-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 1, "--medium", "sdc-#{type}.vmdk", "--type", "hdd"]
    end
    box.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.node_name = user
      chef.json = {
        'splunk' => {
          'type' => "#{type}"
        }
      }
      chef.run_list = [
        "recipe[chef-splunk]"
      ]
    end
  end # Splunk Search Head vbox
  
  ## Splunk Search Pool (NFS server) vbox
  config.vm.define :searchpool do |box|
    type            = 'searchpool'
    box.vm.hostname = "#{ENV['USER']}-#{type}"
    box.vm.box      = boxname
    box.vm.synced_folder "#{ENV['USER']}/.chef", '/etc/chef'   
    box.vm.synced_folder databag_path, "/var/chef/data_bags"
    box.vm.network :private_network, ip: '33.33.33.13', virtualbox__intnet: "mynetwork"
    box.vm.provider :virtualbox do |vb|
      vb.gui = true
      # memory
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
      # create drives
      vb.customize ["createhd", "--filename", "sdb-#{type}", "--size", 20480, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdc-#{type}", "--size", 10240, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdd-#{type}", "--size", 20480, "--format", "VMDK"]
      # create controller
      vb.customize ["storagectl", :id, "--name", "SCSI Controller", "--add", "scsi", "--controller", "LsiLogic", "--bootable", "off"]
      # attach drives to controller
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 0, "--medium", "sdb-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 1, "--medium", "sdc-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 2, "--medium", "sdd-#{type}.vmdk", "--type", "hdd"]
    end
    box.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.node_name = user
      chef.json = {
        'splunk' => {
          'type' => "#{type}"
        }
      }
      chef.run_list = [
        "recipe[chef-splunk]"
      ]
    end
  end # Splunk Search Pool vbox

  ## Splunk Deployment vbox
  config.vm.define :deployserver do |box|
    type            = 'deployserver'
    box.vm.synced_folder "#{ENV['USER']}/.chef", '/etc/chef'
    box.vm.synced_folder databag_path, "/var/chef/data_bags"
    box.vm.hostname = "#{ENV['USER']}-#{type}"
    box.vm.box      = boxname
    box.vm.network :private_network, ip: '33.33.33.11', virtualbox__intnet: "mynetwork"
    box.vm.provider :virtualbox do |vb|
      vb.gui = true
      # memory
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
      # create drives
      vb.customize ["createhd", "--filename", "sdb-#{type}", "--size", 20480, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdc-#{type}", "--size", 10240, "--format", "VMDK"]
      # create controller
      vb.customize ["storagectl", :id, "--name", "SCSI Controller", "--add", "scsi", "--controller", "LsiLogic", "--bootable", "off"]
      # attach drives to controller
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 0, "--medium", "sdb-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 1, "--medium", "sdc-#{type}.vmdk", "--type", "hdd"]
    end
    box.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.node_name = user
      chef.json = {
        'splunk' => {
          'type' => "#{type}"
        }
      }
      chef.run_list = [
        "recipe[chef-splunk]"
      ]
    end
  end # Splunk Deployment vbox

  ## Splunk (IM) Forwarder vbox
  config.vm.define :imforwarder do |box|
    type            = 'imforwarder'
    box.vm.hostname = "#{ENV['USER']}-#{type}"
    box.vm.box      = boxname
    box.vm.synced_folder "#{ENV['USER']}/.chef", '/etc/chef'   
    box.vm.network :private_network, ip: '33.33.33.11', virtualbox__intnet: "mynetwork"
    box.vm.provider :virtualbox do |vb|
      vb.gui = true
      # memory
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--usbehci", "off"]
      # create drives
      vb.customize ["createhd", "--filename", "sdb-#{type}", "--size", 20480, "--format", "VMDK"]
      vb.customize ["createhd", "--filename", "sdc-#{type}", "--size", 10240, "--format", "VMDK"]
      # create controller
      vb.customize ["storagectl", :id, "--name", "SCSI Controller", "--add", "scsi", "--controller", "LsiLogic", "--bootable", "off"]
      # attach drives to controller
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 0, "--medium", "sdb-#{type}.vmdk", "--type", "hdd"]
      vb.customize ["storageattach", :id, "--storagectl", "SCSI Controller", "--port", 1, "--medium", "sdc-#{type}.vmdk", "--type", "hdd"]
    end
    box.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.node_name = user
      chef.json = {
        'splunk' => {
          'type' => "#{type}"
        }
      }
      chef.run_list = [
        "recipe[chef-splunk]"
      ]
    end
  end # Splunk (IM) Forwarder vbox

end
