require_relative '../spec_helper'

describe 'chef-splunk::upgrade' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      :step_into => ['splunk_installer'],
      :platform => 'ubuntu',
      :version => '12.04'
    ) do |node|
      node.set['splunk']['upgrade_enabled'] = true
      node.set['splunk']['accept_license'] = true
      node.set['splunk']['upgrade']['forwarder_url'] = 'http://splunk.example.com/forwarder/package437.deb'
    end.converge(described_recipe)
  end

  it 'stops splunk with a special service resource' do
    expect(chef_run).to stop_service('splunk_stop').with(
      'service_name' => 'splunk'
    )
  end

  it 'downloads the package to install' do
    expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/package437.deb')
  end

  it 'installs the package with splunk_installer' do
    expect(chef_run).to install_package('splunkforwarder')
  end

  it 'runs an unattended upgrade (starts splunk)' do
    expect(chef_run).to run_execute('splunk-unattended-upgrade').with(
      'command' => '/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes'
    )
  end
end
