# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'

github_url = "../Borders"

# Server Configuration

hostname        = "eyp.dev"
public_folder   = "/vagrant"

VAGRANTFILE_API_VERSION = "2"
confDir = $confDir ||= File.expand_path("~/.borders")

bordersYamlPath = confDir + "/Borders.yaml"
aliasesPath = confDir + "/aliases"

require File.expand_path(File.dirname(__FILE__) + '/scripts/borders.rb')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	if File.exists? aliasesPath then
		config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
	end

	Borders.configure(config, YAML::load(File.read(bordersYamlPath)))
end

# ruby_version          = "latest" # Choose what ruby version should be installed (will also be the default version)
# ruby_gems             = [        # List any Ruby Gems that you want to install
  #"jekyll",
#  "sass",
#  "compass",
# ]

# composer_packages     = [        # List any global Composer packages that you want to install
#  "phpunit/phpunit:4.0.*",
  #"codeception/codeception=*",
#  "phpspec/phpspec:2.0.*@dev",
  #"squizlabs/php_codesniffer:1.5.*",
# ]

# nodejs_version        = "latest"   # By default "latest" will equal the latest stable version
# nodejs_packages       = [          # List any global NodeJS packages that you want to install
#  "grunt-cli",
#  "gulp",
#  "bower",
 #"yo",
# ]



# Vagrant.configure("2") do |config|

  # Use NFS for the shared folder
#  config.vm.synced_folder ".", "/vagrant",
#            id: "core",
#            :nfs => true,
#            :mount_options => ['nolock,vers=3,udp,noatime']

  ####
  # Additional Languages
  ##########

  # Install Nodejs
  # config.vm.provision "shell", path: "scripts/nodejs.sh", privileged: false, args: nodejs_packages.unshift(nodejs_version, github_url)

  # Install Ruby Version Manager (RVM)
  # config.vm.provision "shell", path: "scripts/rvm.sh", privileged: false, args: ruby_gems.unshift(ruby_version)

  ####
  # Frameworks and Tooling
  ##########

  # Provision Composer
  #config.vm.provision "shell", path: "scripts/composer.sh", privileged: false, args: composer_packages.join(" ")

  # Provision Laravel
  # config.vm.provision "shell", path: "#{github_url}/scripts/laravel.sh", privileged: false, args: [server_ip, laravel_root_folder, public_folder, laravel_version]  # config.vm.provision "shell", path: "./local-script.sh"

# end
