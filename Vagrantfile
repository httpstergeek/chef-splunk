# -*- mode: ruby -*-
# vi: set ft=ruby :

# tested with vagrant 1.4.1 on Mac OS X 10.8.4

Vagrant.configure("2") do |config|

  config.vm.hostname = "xaal-vagrant"
  config.ssh.username = "vagrant"
  chef_base_path = '~/chef/'
  base_box_url = 'http://y0319p297/'

  # RHEL6 vbox
  config.vm.define :rhel6 do |rhel6|
    rhel6.vm.box = 'nord-rhel64'
    rhel6.vm.box_url = File.join(base_box_url, 'vagrant-RHEL6_4_v1_1.box')
    rhel6.vm.network :private_network, ip: '33.33.33.11'
    rhel6.vm.provider :virtualbox do |vb|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.run_list = [
        "recipe[chef-splunk]"
    ]
  end
end
