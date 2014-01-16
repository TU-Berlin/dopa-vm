# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile for DOPA Virtual Machine
# ---------------------------------
# Uses parts of 
# http://www.mediawiki.org/wiki/Mediawiki-Vagrant
#
# Please report bugs github:
# https://github.com/TU-Berlin/dopa-vm/issues

$DIR = File.expand_path('..', __FILE__); $: << File.join($DIR, 'lib')
require 'mediawiki-vagrant'

Vagrant.configure('2') do |config|

    config.vm.hostname = 'dopa-vm.dev'
    config.package.name = 'dopa.box'

    # Note: If you rely on Vagrant to retrieve the box, it will not
    # verify SSL certificates. If this concerns you, you can retrieve
    # the file using another tool that implements SSL properly, and then
    # point Vagrant to the downloaded file:
    #   $ vagrant box add precise-cloud /path/to/file/precise.box
    config.vm.box = 'precise-cloud'
    config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

    config.vm.network :private_network,
        ip: '10.11.12.13'

    config.vm.network :forwarded_port,
        guest: 8090,
        host: 8090,
        id: 'http',
        auto_correct: true

    config.vm.network :forwarded_port,
        guest: 8081,
        host: 8081,
        id: 'http-2',
        auto_correct: true

    config.vm.network :forwarded_port,
        guest: 8088,
        host: 8088,
        id: 'http-3',
        auto_correct: true

    config.vm.network :forwarded_port,
        guest: 50075,
        host: 50075,
        id: 'http-4',
        auto_correct: true

    config.vm.network :forwarded_port,
        guest: 50070,
        host: 50071,
        id: 'http-5',
        auto_correct: true

    config.vm.network :forwarded_port,
        guest: 55672,
        host: 55672,
        id: 'rabbit-mq-mgnt',
        auto_correct: true
    config.vm.synced_folder '.', '/dopa-vm',
        id: 'vagrant-root',
        owner: 'vagrant',
        group: 'www-data'


    config.vm.provider :virtualbox do |vb|
        # See http://www.virtualbox.org/manual/ch08.html for additional options.
        vb.customize ['modifyvm', :id, '--memory', '3072']
        vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
        vb.customize ['modifyvm', :id, '--ioapic', 'on']

        # To boot the VM in graphical mode, uncomment the following line:
        # vb.gui = true

        # If you are on a single-core system, comment out the following line:
        vb.customize ["modifyvm", :id, '--cpus', '4']
    end

    config.vm.provision :shell do |s|
        # Silence 'stdin: is not a tty' error on Puppet run
        s.inline = 'sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile'
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = 'puppet/modules'
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'

        puppet.options = [
            '--templatedir', '/vagrant/puppet/templates',
            '--verbose',
            '--config_version', '/vagrant/puppet/extra/config-version',
            '--fileserverconfig', '/vagrant/puppet/extra/fileserver.conf',
            '--logdest', "/vagrant/logs/puppet/puppet.#{commit||'unknown'}.log",
            '--logdest', 'console',
        ]
	
        # For more output, uncomment the following line:
         puppet.options << ' --debug'

        # Windows's Command Prompt has poor support for ANSI escape sequences.
        puppet.options << ' --color=false' if windows?
        puppet.facter = $FACTER = {
            'forwarded_port'     => 8081,
            #'shared_apt_cache'   => '/vagrant/apt-cache/',
        }
        #puppet.facter = {
        #    'virtualbox_version' => get_virtualbox_version
        #}
    end

end

begin
    # Load custom Vagrantfile overrides from 'Vagrantfile-extra.rb'
    # See 'Vagrantfile-extra-example.rb' for an example.
    require File.join($DIR, 'Vagrantfile-extra')
rescue LoadError
    # OK. File does not exist.
end
