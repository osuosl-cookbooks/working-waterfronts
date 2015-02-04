# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=2 :
# require 'vagrant-openstack-plugin'
require 'vagrant-omnibus'
require 'vagrant-berkshelf'

box_ver = '20140121'
box_url = "http://vagrant.osuosl.org/centos-6-#{box_ver}.box"

Vagrant.configure('2') do |config|
  config.vm.box       = "centos-6-#{box_ver}"
  config.vm.hostname  = 'project-fish'
  config.vm.box_url   = "#{box_url}"
  config.vm.network :private_network, ip: '33.33.33.50'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this
  # configuration option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the
  # Vagrantfile to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the
  # Vagrantfile to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.omnibus.chef_version = :latest
  config.vm.provision 'chef_solo' do |chef|
    chef.run_list = [
      'recipe[working-waterfronts::default]'
    ]
  end
end

# md5100cf32c205cbe9f41af3c738d12a4ee
# username: postgresql
# password: vagrant
