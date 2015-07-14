# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'

github_url = "../Europa"

# Server Configuration

hostname        = "eyp.dev"
public_folder   = "/vagrant"

VAGRANTFILE_API_VERSION = "2"
confDir = $confDir ||= File.expand_path("~/.europa")

europaYamlPath = confDir + "/Europa.yaml"
aliasesPath = confDir + "/aliases"

require File.expand_path(File.dirname(__FILE__) + '/scripts/europa.rb')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	if File.exists? aliasesPath then
		config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
	end

	Europa.configure(config, YAML::load(File.read(europaYamlPath)))
end

# Vagrant.configure("2") do |config|

  # Use NFS for the shared folder
#  config.vm.synced_folder ".", "/vagrant",
#            id: "core",
#            :nfs => true,
#            :mount_options => ['nolock,vers=3,udp,noatime']

  ####
  # Frameworks and Tooling
  ##########

  # Provision Laravel
  # config.vm.provision "shell", path: "#{github_url}/scripts/laravel.sh", privileged: false, args: [server_ip, laravel_root_folder, public_folder, laravel_version]  # config.vm.provision "shell", path: "./local-script.sh"

# end
